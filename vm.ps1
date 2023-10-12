# change your input and output file path HERE
$inputFilePath = "path/to/SecureEngineCustomVMs_GNU_inline.h"
$outputFilePath = "src/vm.rs"

$inputLines = Get-Content $inputFilePath
$outputLines = @()

$macroName = $null
$assemblyCode = @()
$inAssemblyBlock = $false
$definedMacros = @{}

foreach ($line in $inputLines) {
	if ($line -match "//" -or $line -match "/\*") {
		continue
	}

	if ($line -match "#define\s+(VM_\w+)\s+\\") {
		$macroName = $matches[1].ToLower()
	}

	if ($null -ne $macroName) {
		if ($line -match "__asm__\s+\((.*)") {
			$inAssemblyBlock = $true
		}
		if ($inAssemblyBlock) {
			$cleanedLine = $line -replace '__asm__ \(', '' -replace '\\\"', '`"' -replace '\\\\', '\\' -replace '\\$', ','
			$assemblyCode += $cleanedLine

		}
		if ($line -match "\);") {
			$inAssemblyBlock = $false

			if (-not $definedMacros.ContainsKey($macroName)) {

				$rustMacro = @"
#[macro_export]
macro_rules! $macroName {
    () => {
        unsafe {
            asm!(
$assemblyCode
        }
    };
}
"@
				$outputLines += $rustMacro
				$definedMacros[$macroName] = $true

			}
			$macroName = $null
			$assemblyCode = @()
		}
	}
}

$assemblyCode = $assemblyCode -join "`n                "

$outputLines | Out-File $outputFilePath -Encoding utf8
