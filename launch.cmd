@echo off
:: ------------------------------- ::
:: Launcher script for comfy-ui    ::
:: - Uses a venv to install        ::
::   requirements                  ::
:: ------------------------------- ::

:: venv directory
SET VENV=.venv
:: venv creation arguments
SET VENV_ARGS=--upgrade-deps

:: global python interpreter
SET PYTHON="C:\Program Files\Python\Python310\Python.exe"

:: pip config
:: as passed to python interpreter (e.g. with -m)
:: Sidenote: If this consumes 100% RAM, and kills disk IO
:: try ::oving `-q -q`
SET PIP=-m pip install
:: additional pip arguments
:: requi::ents.txt
SET REQUIREMENTS_FILE=requirements.txt

:: create and initialize venv if needed
SET DO_DEPS=0
IF NOT EXIST "%VENV%" (
	:: create
	ECHO Creating python venv at '%VENV%'
	%PYTHON% -m venv %VENV_ARGS% %VENV%

	SET DO_DEPS=1
)

:: update python interpreter
SET PYTHON="%VENV%/Scripts/python.exe"

:: validate interpreter path
IF EXIST %PYTHON% (
	ECHO Python interpreter:
	%PYTHON% -c "import sys; print(sys.executable)"
) ELSE (
	ECHO venv not found!
	GOTO :EXIT
)

:: install dependencies if neccessary
IF "%DO_DEPS%"=="1" (
	ECHO Installing torch...
	%PYTHON% %PIP% torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

	:: test cuda ;; TODO: This should probably crash if it fails...
	Echo Testing cuda...
	%PYTHON% -c "import torch; print(torch.cuda.is_available())"

	ECHO Installing xformers...
	%PYTHON% %PIP% xformers
	ECHO Installing additional requirements...
	%PYTHON% %PIP% -r %REQUIREMENTS_FILE%

	:: install deps for custom nodes
	ECHO Installing WAS requirements
	%PYTHON% %PIP% -r "./custom_nodes/was-node-suite-comfyui/requirements.txt"
)

SET PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.7,max_split_size_mb:512

:: launch? :)
ECHO Launching comfy ui...
%PYTHON% main.py

ECHO ComfyUI returned with %errorlevel%

:EXIT