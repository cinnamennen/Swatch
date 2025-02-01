@echo off
setlocal EnableDelayedExpansion

:: ===========================
:: Configuration Section
:: ===========================
:: Check if OpenSCAD and PrusaSlicer paths are set
if not defined OPENSCAD_PATH (
    set "OPENSCAD_PATH=C:\Progra~1\OpenSC~1\openscad.exe"
)
if not defined PRUSASLICER_PATH (
    set "PRUSASLICER_PATH=C:\Progra~1\Prusa3D\PrusaS~1\prusa-slicer-console.exe"
)

:: Verify required tools exist
call :check_tool "%OPENSCAD_PATH%" "OpenSCAD"
call :check_tool "%PRUSASLICER_PATH%" "PrusaSlicer"

:: Check for required files
call :check_file "Configurable_Filament_Swatch_Bevelled_VZF.scad"
call :check_file "filaments.csv"

:: ===========================
:: Prepare Output Directories
:: ===========================
if not exist "output\stl" mkdir "output\stl"
if not exist "output\gcode" mkdir "output\gcode"

:: ===========================
:: Read CSV and Process Each Line
:: ===========================
set "CSV_FILE=%~1"
if "%CSV_FILE%"=="" set "CSV_FILE=filaments.csv"

for /f "usebackq skip=1 tokens=1-3 delims=," %%a in ("%CSV_FILE%") do (
    set "material=%%a"
    set "brand=%%b"
    set "color=%%c"
    
    call :process_material "!material!" "!brand!" "!color!"
)

:: ===========================
:: Clean Up
:: ===========================
if exist "output\gcode\*.gcode" (
    echo Cleaning up temporary files...
    rmdir /s /q "output\stl"
) else (
    echo No GCODE files were generated, keeping STL files for troubleshooting
)

echo Done! Generated gcode files are in output\gcode\
exit /b

:: ===========================
:: Subroutines
:: ===========================
:check_tool
if not exist %1 (
    echo %2 not found at: %1
    echo Please install %2 or set the appropriate environment variable
    exit /b 1
)
exit /b

:check_file
if not exist %1 (
    echo Required file %1 not found.
    exit /b 1
)
exit /b

:read_ini_value
set "ini_file=%~1"
set "search_key=%~2"
set "default_value=%~3"

echo DEBUG: Reading from "%ini_file%", searching for "%search_key%"

:: First try exact match
for /f "usebackq tokens=1,* delims==" %%A in (`findstr /b /i "%search_key% =" "%ini_file%"`) do (
    set "found_key=%%A"
    set "found_value=%%B"
    echo DEBUG: Found exact match - Key: "!found_key!" Value: "!found_value!"
    :: Trim spaces
    set "found_key=!found_key: =!"
    set "found_value=!found_value: =!"
    if /I "!found_key!"=="%search_key%" (
        echo DEBUG: Key matches, setting result to: "!found_value!"
        set "result=!found_value!"
        exit /b 0
    )
)

:: If no exact match found, try reading line by line
for /f "usebackq tokens=1,* delims==" %%A in ("%ini_file%") do (
    set "line_key=%%A"
    set "line_value=%%B"
    :: Trim spaces
    set "line_key=!line_key: =!"
    if /I "!line_key!"=="%search_key%" (
        echo DEBUG: Found match in full file - Key: "!line_key!" Value: "!line_value!"
        set "result=!line_value!"
        exit /b 0
    )
)

echo DEBUG: Key not found, using default: "%default_value%"
set "result=%default_value%"
exit /b 1

:process_material
set "material=%~1"
set "brand=%~2"
set "color=%~3"

:: Define top_text with spaces between each character of material
set "top_text="
for /L %%i in (0,1,31) do (
    set "char=!material:~%%i,1!"
    if not "!char!"=="" (
        set "top_text=!top_text! !char!"
    )
)
:: Remove leading space
set "top_text=!top_text:~1!"

:: Define reusable variables for STL and GCODE file names
set "stl_file=output\stl\!brand!_!material!_!color!.stl"
set "gcode_file=output\gcode\!brand!_!material!_!color!.bgcode"

:: Determine which config file to use based on material and brand
set "config_file="
if /I "!brand!"=="Prusament" (
    if /I "!material!"=="PLA" set "config_file=config_prusament_pla.ini"
    if /I "!material!"=="PETG" set "config_file=config_prusament_petg.ini"
    if /I "!material!"=="PLA Blend" set "config_file=config_prusament_pla_blend.ini"
    if /I "!material!"=="rPLA" set "config_file=config_prusament_rpla.ini"
) else (
    if /I "!material!"=="PLA" set "config_file=config_generic_pla.ini"
    if /I "!material!"=="PETG" set "config_file=config_generic_petg.ini"
    if /I "!material!"=="PLA Silk" set "config_file=config_generic_pla_silk.ini"
)

if not exist "!config_file!" (
    echo Config file !config_file! not found, skipping material !material! !brand!
    exit /b
)

:: Read configuration values - new simplified approach
for /f "usebackq tokens=1,* delims==" %%a in ("!config_file!") do (
    set "key=%%a"
    set "value=%%b"
    :: Remove spaces
    set "key=!key: =!"
    set "value=!value: =!"
    
    if /I "!key!"=="layer_height" (
        set "layer_height=!value!"
        :: Strip leading zero if present
        if "!layer_height:~0,2!"=="0." set "layer_height=.!layer_height:~2!"
        echo Found layer_height: !layer_height!
    )
    if /I "!key!"=="temperature" (
        for /f "tokens=1 delims=," %%t in ("!value!") do (
            set "nozzle_temp=%%t"
            echo Found temperature: !nozzle_temp!
        )
    )
)

:: Generate STL using command line parameters
echo Generating STL for !material! !color!...
"!OPENSCAD_PATH!" --backend=Manifold -o "!stl_file!" ^
    -D "textstring_Material=\"!material!\"" ^
    -D "textstring1=\"!brand!\"" ^
    -D "textstring2=\"!layer_height!  !nozzle_temp!C\"" ^
    -D "textstring3=\"!color!\"" ^
    -D "texttop=\" !top_text!\"" ^
    "Configurable_Filament_Swatch_Bevelled_VZF.scad"

if not exist "!stl_file!" (
    echo Failed to generate STL for !material! !color!
    exit /b
)

:: Slice STL to GCODE
echo Slicing !material! !color! using !config_file!...
"!PRUSASLICER_PATH!" ^
    --load "!config_file!" ^
    --output "!gcode_file!" ^
    --slice ^
    --export-gcode ^
    "!stl_file!"

if not exist "!gcode_file!" (
    echo Failed to generate GCODE for !material! !color!
)

exit /b 