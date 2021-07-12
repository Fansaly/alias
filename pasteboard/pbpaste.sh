#!/bin/bash

powershell.exe Get-Clipboard | sed 's/\r$//'
