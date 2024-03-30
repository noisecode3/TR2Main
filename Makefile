# TR2Main Wine Build for Proton/Wine
CC = winegcc
CXX = wineg++
RC = wrc
AR = ar

DXCONFIG := \
    -D_RELEASE \
    -DDIRECT3D_VERSION=0x900 \
    -DDIRECTINPUT_VERSION=0x900 \
    -DDIRECTSOUND_VERSION=0x900 

CONFIG := \
    -DBUILD_DLL \
    -D_WIN32_WINNT=0x501 \
    -DFEATURE_ASSAULT_SAVE \
    -DFEATURE_AUDIO_IMPROVED \
    -DFEATURE_BACKGROUND_IMPROVED \
    -DFEATURE_CHEAT \
    -DFEATURE_EXTENDED_LIMITS \
    -DFEATURE_FFPLAY \
    -DFEATURE_GAMEPLAY_FIXES \
    -DFEATURE_GOLD \
    -DFEATURE_HUD_IMPROVED \
    -DFEATURE_INPUT_IMPROVED \
    -DFEATURE_MOD_CONFIG \
    -DFEATURE_NOCD_DATA \
    -DFEATURE_NOLEGACY_OPTIONS \
    -DFEATURE_PAULD_CDAUDIO \
    -DFEATURE_SCREENSHOT_IMPROVED \
    -DFEATURE_SUBFOLDERS \
    -DFEATURE_VIDEOFX_IMPROVED \
    -DFEATURE_VIEW_IMPROVED \
    -DFEATURE_WINDOW_STYLE_FIX

CFLAGS := \
    -m32 \
    -O3 \
    -fvisibility=hidden \
    -Wall \
    -Wextra \
    -Wpedantic \
    -Wno-unused-parameter \
    -Winvalid-pch \
    -Wno-unknown-pragmas \
    -s

CXXFLAGS := \
    -m32 \
    -O3 \
    -fvisibility=hidden \
    -Wall \
    -Wextra \
    -Wpedantic \
    -Wno-unused-parameter \
    -Winvalid-pch \
    -Wno-unknown-pragmas \
    -s

# Define source directories, those should not mix definitions
SRC_PRE := global/precompiled.h
SRC_GAME_DIR := game
SRC_GLOBAL_DIR := global
SRC_MODDING_DIR := modding
SRC_3DSYSTEM_DIR := 3dsystem
SRC_SPECIFIC_DIR := specific
SRC_JSON_PARSER_DIR := json-parser

# Define object directories
OBJ_PRE := obj/DX9Wine-Release/global/precompiled.h.gch
OBJ_GAME_DIR := obj/DX9Wine-Release/game
OBJ_GLOBAL_DIR := obj/DX9Wine-Release/global
OBJ_MODDING_DIR := obj/DX9Wine-Release/modding
OBJ_3DSYSTEM_DIR := obj/DX9Wine-Release/3dsystem
OBJ_SPECIFIC_DIR := obj/DX9Wine-Release/specific
OBJ_JSON_PARSER_DIR := obj/DX9Wine-Release/json-parser

# Collect all source files
SRCS_C_GAME := $(wildcard $(SRC_GAME_DIR)/*.c)
SRCS_CPP_GAME := $(wildcard $(SRC_GAME_DIR)/*.cpp)

SRCS_C_GLOBAL := $(wildcard $(SRC_GLOBAL_DIR)/*.c)
SRCS_CPP_GLOBAL := $(wildcard $(SRC_GLOBAL_DIR)/*.cpp)

SRCS_C_MODDING := $(wildcard $(SRC_MODDING_DIR)/*.c)
SRCS_CPP_MODDING := $(wildcard $(SRC_MODDING_DIR)/*.cpp)

SRCS_C_3DSYSTEM := $(wildcard $(SRC_3DSYSTEM_DIR)/*.c)
SRCS_CPP_3DSYSTEM := $(wildcard $(SRC_3DSYSTEM_DIR)/*.cpp)

SRCS_C_SPECIFIC := $(wildcard $(SRC_SPECIFIC_DIR)/*.c)
SRCS_CPP_SPECIFIC := $(wildcard $(SRC_SPECIFIC_DIR)/*.cpp)

SRCS_C_JSON_PARSER := $(wildcard $(SRC_JSON_PARSER_DIR)/*.c)
SRCS_CPP_JSON_PARSER := $(wildcard $(SRC_JSON_PARSER_DIR)/*.cpp)

# Generate object file names
OBJS_C_GAME := $(patsubst $(SRC_GAME_DIR)/%.c,$(OBJ_GAME_DIR)/%.o,$(SRCS_C_GAME))
OBJS_CPP_GAME := $(patsubst $(SRC_GAME_DIR)/%.cpp,$(OBJ_GAME_DIR)/%.o,$(SRCS_CPP_GAME))

OBJS_C_GLOBAL := $(patsubst $(SRC_GLOBAL_DIR)/%.c,$(OBJ_GLOBAL_DIR)/%.o,$(SRCS_C_GLOBAL))
OBJS_CPP_GLOBAL := $(patsubst $(SRC_GLOBAL_DIR)/%.cpp,$(OBJ_GLOBAL_DIR)/%.o,$(SRCS_CPP_GLOBAL))

OBJS_C_MODDING := $(patsubst $(SRC_MODDING_DIR)/%.c,$(OBJ_MODDING_DIR)/%.o,$(SRCS_C_MODDING))
OBJS_CPP_MODDING := $(patsubst $(SRC_MODDING_DIR)/%.cpp,$(OBJ_MODDING_DIR)/%.o,$(SRCS_CPP_MODDING))

OBJS_C_3DSYSTEM := $(patsubst $(SRC_3DSYSTEM_DIR)/%.c,$(OBJ_3DSYSTEM_DIR)/%.o,$(SRCS_C_3DSYSTEM))
OBJS_CPP_3DSYSTEM := $(patsubst $(SRC_3DSYSTEM_DIR)/%.cpp,$(OBJ_3DSYSTEM_DIR)/%.o,$(SRCS_CPP_3DSYSTEM))

OBJS_C_SPECIFIC := $(patsubst $(SRC_SPECIFIC_DIR)/%.c,$(OBJ_SPECIFIC_DIR)/%.o,$(SRCS_C_SPECIFIC))
OBJS_CPP_SPECIFIC := $(patsubst $(SRC_SPECIFIC_DIR)/%.cpp,$(OBJ_SPECIFIC_DIR)/%.o,$(SRCS_CPP_SPECIFIC))

OBJS_C_JSON_PARSER := $(patsubst $(SRC_JSON_PARSER_DIR)/%.c,$(OBJ_JSON_PARSER_DIR)/%.o,$(SRCS_C_JSON_PARSER))
OBJS_CPP_JSON_PARSER := $(patsubst $(SRC_JSON_PARSER_DIR)/%.cpp,$(OBJ_JSON_PARSER_DIR)/%.o,$(SRCS_CPP_JSON_PARSER))


ALL_OBJS := $(OBJS_C_GAME) $(OBJS_CPP_GAME) \
            $(OBJS_C_GLOBAL) $(OBJS_CPP_GLOBAL) \
            $(OBJS_C_MODDING) $(OBJS_CPP_MODDING) \
            $(OBJS_C_3DSYSTEM) $(OBJS_CPP_3DSYSTEM) \
            $(OBJS_C_SPECIFIC) $(OBJS_CPP_SPECIFIC) \
            $(OBJS_C_JSON_PARSER) $(OBJS_CPP_JSON_PARSER)


GAME_EXTRA := -iquoteobj\DX9Wine-Release\game \
	      -Iobj\DX9Wine-Release\game -I.

GLOBAL_EXTRA := -iquoteobj\DX9Wine-Release\global \
	        -Iobj\DX9Wine-Release\global -I.

MODDING_EXTRA := -iquoteobj\DX9Wine-Release\modding \
	         -Iobj\DX9Wine-Release\modding -I.

3DSYSTEM_EXTRA := -iquoteobj\DX9Wine-Release\3dsystem \
	          -Iobj\DX9Wine-Release\3dsystem -I.

SPECIFIC_EXTRA := -iquoteobj\DX9Wine-Release\specific \
	          -Iobj\DX9Wine-Release\specific -I.

JSON_PARSER_EXTRA := -iquoteobj\DX9Wine-Release\json-parser \
	             -Iobj\DX9Wine-Release\json-parser -I.

.PHONY: dirsetup
dirsetup:
	@mkdir -p $(OBJ_GAME_DIR)
	@mkdir -p $(OBJ_GLOBAL_DIR)
	@mkdir -p $(OBJ_MODDING_DIR)
	@mkdir -p $(OBJ_3DSYSTEM_DIR)
	@mkdir -p $(OBJ_SPECIFIC_DIR)
	@mkdir -p $(OBJ_JSON_PARSER_DIR)

.DEFAULT_GOAL := build





# Target Wine
TARGET := bin/DX9Wine-Release/TR2Main.dll

all: $(TARGET) $(OBJ_PRE)

$(OBJ_PRE): $(SRC_PRE)
	$(CXX) $(CXXFLAGS) $(CONFIG) $(DXCONFIG) -c -o $@ $<

$(TARGET): $(ALL_OBJS)

# Rule to compile each .c file into a .o file
$(OBJ_GAME_DIR)/%.o: $(SRC_GAME_DIR)/%.c | $(OBJ_GAME_DIR)
	$(CC) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(GAME_EXTRA) -c $< -o $@

$(OBJ_GLOBAL_DIR)/%.o: $(SRC_GLOBAL_DIR)/%.c | $(OBJ_GLOBAL_DIR)
	$(CC) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(GLOBAL_EXTRA) -c $< -o $@

$(OBJ_MODDING_DIR)/%.o: $(SRC_MODDING_DIR)/%.c | $(OBJ_MODDING_DIR)
	$(CC) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(MODDING_EXTRA) -c $< -o $@

$(OBJ_3DSYSTEM_DIR)/%.o: $(SRC_3DSYSTEM_DIR)/%.c | $(OBJ_3DSYSTEM_DIR)
	$(CC) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(3DSYSTEM_EXTRA) -c $< -o $@

$(OBJ_SPECIFIC_DIR)/%.o: $(SRC_SPECIFIC_DIR)/%.c | $(OBJ_SPECIFIC_DIR)
	$(CC) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(SPECIFIC_EXTRA) -c $< -o $@

$(OBJ_JSON_PARSER_DIR)/%.o: $(SRC_JSON_PARSER_DIR)/%.c | $(OBJ_JSON_PARSER_DIR)
	$(CC) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(JSON_PARSER_EXTRA) -c $< -o $@

# Rule to compile each .cpp file into a .o file
$(OBJ_GAME_DIR)/%.o: $(SRC_GAME_DIR)/%.cpp | $(OBJ_GAME_DIR)
	$(CXX) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(GAME_EXTRA) -c $< -o $@

$(OBJ_GLOBAL_DIR)/%.o: $(SRC_GLOBAL_DIR)/%.cpp | $(OBJ_GLOBAL_DIR)
	$(CXX) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(GLOBAL_EXTRA) -c $< -o $@

$(OBJ_MODDING_DIR)/%.o: $(SRC_MODDING_DIR)/%.cpp | $(OBJ_MODDING_DIR)
	$(CXX) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(MODDING_EXTRA) -c $< -o $@

$(OBJ_3DSYSTEM_DIR)/%.o: $(SRC_3DSYSTEM_DIR)/%.cpp | $(OBJ_3DSYSTEM_DIR)
	$(CXX) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(3DSYSTEM_EXTRA) -c $< -o $@

$(OBJ_SPECIFIC_DIR)/%.o: $(SRC_SPECIFIC_DIR)/%.cpp | $(OBJ_SPECIFIC_DIR)
	$(CXX) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(SPECIFIC_EXTRA) -c $< -o $@

$(OBJ_JSON_PARSER_DIR)/%.o: $(SRC_JSON_PARSER_DIR)/%.cpp | $(OBJ_JSON_PARSER_DIR)
	$(CXX) $(CFLAGS) $(CONFIG) $(DXCONFIG) $(JSON_PARSER_EXTRA)  -c $< -o $@

# Main Rule
# It can compile but don't resolve linking

obj/DX9Wine-Release/TR2Main.rc.res: TR2Main.rc
	$(RC) $(RCFLAGS) -fo$@ $<

$(TARGET): ${OBJ_PRE} $(ALL_OBJS) obj/DX9Wine-Release/TR2Main.rc.res
	mkdir -p bin/DX9Wine-Release
	$(CXX) -shared -Wl,--out-implib=bin\DX9Wine-Release\libTR2Main.a -Wl,--dll -o $@ $^ \
		-static-libstdc++ -static-libgcc -m32 -s  -luser32 -lshell32 -lgdi32 -lgdiplus \
		-lcomctl32 -lshlwapi -lwinmm -lhid -lole32 -loleaut32 -lsetupapi -ldxguid -ld3d9 \
		-ld3dx9 -ldinput8 -ldsound

.PHONY: setup
setup:
	echo "there is only input and image file handling issues, eveything else compile" 

# Phony target that runs setup before building
.PHONY: build
build: setup dirsetup all

.PHONY: clean
clean:
	rm -fr obj/DX9Wine-Release $(TARGET)

