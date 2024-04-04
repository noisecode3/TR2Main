/*
 * Copyright (c) 2017-2018 Michael Chaban. All rights reserved.
 * Original game is created by Core Design Ltd. in 1997.
 * Lara Croft and Tomb Raider are trademarks of Embracer Group AB.
 *
 * This file is part of TR2Main.
 *
 * TR2Main is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * TR2Main is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with TR2Main.  If not, see <http://www.gnu.org/licenses/>.
 */

// TODO: I made it compile BUT there is logical errors now
// It could work with FreeImage and/or wines weird half implemented gdi+

#include "global/precompiled.h"
#include "modding/gdi_utils.h"
#include "global/vars.h"
#include <gdiplus.h>
#include <windows.h>
/*
#include <FreeImage.h>

bool GetImageDimensions(const char* filename, int& width, int& height) {
    // Load the image file
    FREE_IMAGE_FORMAT fif = FreeImage_GetFileType(filename, 0);
    FIBITMAP* image = FreeImage_Load(fif, filename, 0);

    // Check if the image was successfully loaded
    if (!image) {
        // Handle error: failed to load image
        return false;
    }

    // Get the width and height of the image
    width = FreeImage_GetWidth(image);
    height = FreeImage_GetHeight(image);

    // Unload the image from memory
    FreeImage_Unload(image);

    return true;
}


static const WCHAR GDI_Encoders[3] = {
     L"image/bmp",
     L"image/jpeg",
     L"image/png"
};

 */
static ULONG_PTR GDI_Token = 0;

static int GetEncoderClsid(const WCHAR *format, CLSID *pClsid) {
	unsigned int num = 0, nSize = 0;
	Gdiplus::DllExports::GdipGetImageEncodersSize(&num, &nSize);
	if( nSize == 0 ) {
		return -1;
	}
	Gdiplus::ImageCodecInfo *pImageCodecInfo = (Gdiplus::ImageCodecInfo *)malloc(nSize);
	if( pImageCodecInfo == NULL ) {
		return -1;
	}
	Gdiplus::DllExports::GdipGetImageEncoders(num, nSize, pImageCodecInfo);

	for( DWORD j = 0; j < num; ++j) {
		if( pImageCodecInfo[j].MimeType == 0 ) { //bug format[j]
			*pClsid = pImageCodecInfo[j].Clsid;
			free(pImageCodecInfo);
			return j;
		}
	}
	free(pImageCodecInfo);
	return -1;
}
HBITMAP CreateBitmapFromDC(HDC dc, RECT *rect, LPVOID *lpBits, PALETTEENTRY *pal) {
	if( dc == NULL || rect == NULL || lpBits == NULL ) {
		return NULL; // wrong parameters
	}

	WORD nBPP = GetDeviceCaps(dc, BITSPIXEL);
	int width  = ABS(rect->right  - rect->left);
	int height = ABS(rect->bottom - rect->top);

	HDC hdcDestination = CreateCompatibleDC(dc);
	DWORD infoSize = sizeof(BITMAPINFOHEADER) + 256 * sizeof(RGBQUAD);
	BITMAPINFO *info = (BITMAPINFO *)malloc(infoSize);

	if( info == NULL ) {
		DeleteDC(hdcDestination);
		return NULL; // failed to create bitmap info
	}

	memset(info, 0, infoSize);
	info->bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	info->bmiHeader.biWidth = width;
	info->bmiHeader.biHeight = -height;
	info->bmiHeader.biPlanes = 1;
	info->bmiHeader.biBitCount = nBPP;
	info->bmiHeader.biCompression = BI_RGB;

	if( pal != NULL ) {
		for( int i = 0; i < 256; ++i ) {
			info->bmiColors[i].rgbRed   = pal[i].peRed;
			info->bmiColors[i].rgbGreen = pal[i].peGreen;
			info->bmiColors[i].rgbBlue  = pal[i].peBlue;
		}
	}

	HBITMAP hbmDestination = CreateDIBSection(dc, info, DIB_RGB_COLORS, lpBits, NULL, 0);
	free(info);

	if( hbmDestination == NULL ) {
		DeleteDC(hdcDestination);
		return NULL; // failed to create bitmap
	}

	int stateDestination = SaveDC(hdcDestination);
	SelectObject(hdcDestination, hbmDestination);
	BitBlt(hdcDestination, 0, 0, width, height, dc, rect->left, rect->top, SRCCOPY);
	RestoreDC(hdcDestination, stateDestination);
	DeleteDC(hdcDestination);

	return hbmDestination;
}

bool __cdecl GDI_Init() {
	if( !GDI_Token ) {
		Gdiplus::GdiplusStartupInput gdiplusStartupInput;
		Gdiplus::GdiplusStartup(&GDI_Token, &gdiplusStartupInput, NULL);
	}
	return ( GDI_Token != 0 );
}

void __cdecl GDI_Cleanup() {
	if( GDI_Token ) {
		Gdiplus::GdiplusShutdown(GDI_Token);
		GDI_Token = 0;
	}
}

int GDI_SaveImageFile(LPCSTR filename, GDI_FILEFMT format, DWORD quality, HBITMAP hbmBitmap) {
	if( filename == NULL || !*filename || hbmBitmap == NULL ) {
		return -1; // wrong parameters
	}

	if( format < 0 || format >= ARRAY_SIZE("") ) {
		return -1; // wrong format
	}

	Gdiplus::Status status = Gdiplus::Ok;

	CLSID imageCLSID;
        Gdiplus::GpBitmap **gdi_bitmap;
        Gdiplus::DllExports::GdipCreateBitmapFromHBITMAP(hbmBitmap, (HPALETTE)NULL, gdi_bitmap);
	if( gdi_bitmap == NULL ) {
		return -1;
	}

	Gdiplus::EncoderParameters encoderParams;
	encoderParams.Count = 1;
	encoderParams.Parameter[0].NumberOfValues = 1;
	//encoderParams.Parameter[0].Guid  = EncoderQuality;
	encoderParams.Parameter[0].Type  = Gdiplus::EncoderParameterValueTypeLong;
	encoderParams.Parameter[0].Value = &quality;
	//GetEncoderClsid(GDI_Encoders[format], &imageCLSID);

#ifdef UNICODE
	status = gdi_bitmap->Save(filename, &imageCLSID, &encoderParams);
#else // !UNICODE
	{
		WCHAR wc_fname[MAX_PATH] = {0};
		if( !MultiByteToWideChar(CP_ACP, 0, filename, strlen(filename), wc_fname, MAX_PATH) ) {
			delete gdi_bitmap;
			return -1;
		}

                //status = Gdiplus::DllExports::GdipSaveImageToFile(gdi_bitmap, wc_fname, &imageCLSID, &encoderParams);
	}
#endif // UNICODE

	delete gdi_bitmap;
	return ( status == Gdiplus::Ok ) ? 0 : -1;
}


int GDI_LoadImageFile(LPCSTR filename, BYTE **bmPtr, DWORD *width, DWORD *height, DWORD bpp) {
	if( filename == NULL || !*filename || bmPtr == NULL || width == NULL || height == NULL ) {
		return -1; // wrong parameters
	}

	DWORD i;
	int result = 0;
	DWORD bmSize = 0;
	BYTE *src = NULL;
	BYTE *dst = NULL;
	Gdiplus::GpBitmap *gdi_bitmap = NULL;
	Gdiplus::BitmapData bmData;
	Gdiplus::Status status;
	Gdiplus::PixelFormat pixelFmt;

	switch( bpp ) {
		case 32 :
			pixelFmt = PixelFormat32bppARGB;
			break;
		case 16 :
			pixelFmt = PixelFormat16bppARGB1555;
			break;
		default :
			// unsupported pixel format;
			return -1;
			break;
	}

#ifdef UNICODE
	gdi_bitmap = new Bitmap(filename);
#else // !UNICODE
	{
		WCHAR wc_fname[MAX_PATH] = {0};
		if( !MultiByteToWideChar(CP_ACP, 0, filename, strlen(filename), wc_fname, MAX_PATH) ) {
			// failed to get UNICODE filename
			result = -1;
			goto CLEANUP;
		}
                Gdiplus::GpBitmap **gdi_bitmap;
                Gdiplus::DllExports::GdipCreateBitmapFromFile(wc_fname, gdi_bitmap);
	}
#endif // UNICODE

	if( gdi_bitmap == NULL ) {
		// failed to create gdi_bitmap
		result = -1;
		goto CLEANUP;
	}

	*width = 0;
	*height = 0;
	//*width = gdi_bitmap->width;
	//*height = gdi_bitmap->GetHeight();

	bmSize = (*width) * (*height) * (bpp/8);
	*bmPtr = (BYTE *)malloc(bmSize * (bpp/8));
	if( *bmPtr == NULL ) {
		// failed to allocate output bitmap
		result = -1;
		goto CLEANUP;
	}

	{ // rect is temporary here
		Gdiplus::GpRect rect;
                //(0, 0, *width, *height);
		
                status = Gdiplus::DllExports::GdipBitmapLockBits(gdi_bitmap ,&rect ,Gdiplus::ImageLockModeRead, pixelFmt, &bmData);
	}

	if( status != Gdiplus::Ok ) {
		// failed to lock the bitmap
		free(bmPtr);
		result = -1;
		goto CLEANUP;
	}

	src = (BYTE *)bmData.Scan0;
	if( bmData.Stride < 0 ) {
		src += ABS(bmData.Stride) * (*height - 1);
	}

	dst = *bmPtr;
	for( i = 0; i < *height; ++i ) {
		memcpy(dst, src, (*width) * (bpp/8));
		dst += (*width) * (bpp/8);
		src += bmData.Stride;
	}

        Gdiplus::DllExports::GdipBitmapUnlockBits(gdi_bitmap,&bmData);

CLEANUP :
	if( gdi_bitmap != NULL ) {
		delete gdi_bitmap;
		gdi_bitmap = NULL;
	}
	return result;
}
