# change your input and output file path HERE
$inputFilePath = "path/to/ThemidaSDK.h"
$outputFilePath = "src/sdk.rs"

$inputLines = Get-Content $inputFilePath

$inAssemblyBlock = $false
$assemblyCode = @()
$outputLines = @()
$macroName = $null
$gnuCount = 0

# we ignore those functions for now
$ignoreFunctions = @(
	"CHECK_CODE_INTEGRITY",
	"CHECK_REGISTRATION",
	"CHECK_VIRTUAL_PC",
	"CHECK_PROTECTION",
	"VM_START_WITHLEVEL"
)

$generatedMacros = @{}


foreach ($line in $inputLines) {
	if ($line -match "#ifdef __GNUC__") {
		$gnuCount++
		if ($gnuCount -eq 4) {
			$inAssemblyBlock = $true
		}
		continue
	}
	elseif ($line -match "#else") {
		if ($inAssemblyBlock) {
			$inAssemblyBlock = $false
			break
		}
	}

	if (-not $inAssemblyBlock) {
		continue
	}

	if ($line -match "NO_OPTIMIZATION" -or $line.StartsWith("//") -or $line.StartsWith("/*")) {
		continue
	}

	if ($line -match "#define (.+?)\((.+?)\) \\") {
		$macroName = $matches[1]
		if ($ignoreFunctions -contains $macroName -or $generatedMacros.ContainsKey($macroName)) {
			$macroName = $null
			continue
		}
		$macroName = $macroName.ToLower()
		continue
	}
	elseif ($line -match "#define (.+?) \\") {
		$macroName = $matches[1]
		if ($ignoreFunctions -contains $macroName -or $generatedMacros.ContainsKey($macroName)) {
			$macroName = $null
			continue
		}
		$macroName = $macroName.ToLower()
		continue
	}

	if ($line -match "\);") {
		$assemblyCode += $inputLines[[array]::IndexOf($inputLines, $line) - 1] -replace 'asm\(', '' -replace '\\\"', '`"' -replace '\\\\', '\\' -replace '\\$', ',' -replace '\);', ''

		if ($null -ne $macroName) {
			$rustMacro = @"
#[macro_export]
macro_rules! $macroName {
    () => {
        unsafe {
            asm!(
$assemblyCode
            );
        }
    };
}
"@
			$outputLines += $rustMacro
			$generatedMacros[$macroName] = $true
		}

		$macroName = $null
		$assemblyCode = @()
		continue
	}

	if ($macroName) {
		$cleanedLine = $line -replace 'asm\(', '' -replace '\\\"', '`"' -replace '\\\\', '\\' -replace '\\$', ',' -replace '\);', ''
		if ($line -match "\\n$") {
			$cleanedLine += "\n"
		}
		$assemblyCode += $cleanedLine
	}

}

$outputLines | Out-File $outputFilePath -Encoding utf8