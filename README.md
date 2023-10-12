# Rust Bindings for ThemidaSDK

This repo contains Generators for creating Rust bindings from the ThemidaSDK

If you're looking to use ThemidaSDK's VM protection macros (and other macros) in your Rust project, you're in the right place!

## Pre-requisites

Make sure to update the paths to `ThemidaSDK.h` and `SecureEngineCustomVMs_GNU_inline.h` in the Powershell Scripts.

They are usually found in the ThemidaSDK/include/C directory.

Also, for the macros to work correctly, you need to ensure that `SecureEngineSDK64.dll` is accessible by your Rust project.

There are a couple of ways to achieve this:

### Method 1: Update the Build Script

1. Place the `SecureEngineSDK64.dll` in a directory, e.g., `./lib`.
2. Update the `build.rs` file to point to the directory containing the DLL:

    ```rust
    fn main() {
        println!("cargo:rustc-link-search=native=./lib");
        println!("cargo:rustc-link-lib=dylib=SecureEngineSDK64");
    }
    ```

### Method 2: Update the PATH Environment Variable

1. Locate the directory containing `SecureEngineSDK64.dll`.
2. Add this directory to the `PATH` environment variable:
    - Right-click on "This PC" or "My Computer" on your desktop or in File Explorer.
    - Choose "Properties."
    - Click on "Advanced system settings."
    - Click on "Environment Variables."
    - In the "System variables" section, scroll down and select the "Path" variable, then click on "Edit."
    - In the Edit Environment Variable window, click "New" and then paste the full path to the directory that contains `SecureEngineSDK64.dll`.
    - Click "OK" to close each window.

## Verifying the Setup

To verify that the `PATH` environment variable has been updated correctly, open a new Command Prompt window and run the following command:

```shell
echo %PATH%
```

## Generating Rust Macros

Two PowerShell scripts are provided to help generate Rust macros from the C definitions in ThemidaSDK.

One is for all the Vm's (vm.ps1) and the other one for the rest of the macros (sdk.ps1).

Just run the script, and they'll do the heavy lifting, converting C to Rust macros.

## How to Use

Once the macros are generated, import them in your Rust files, and you're good to go:

```rust
extern crate themida_sdk_rust_bindings;

use themida_sdk_rust_bindings::*;

fn main() {
    vm_start!();
    // Your protected code here
    vm_end!();
}
```

## Known Limitations

The script currently skips the following functions:

- CHECK_CODE_INTEGRITY
- CHECK_REGISTRATION
- CHECK_VIRTUAL_PC
- CHECK_PROTECTION
- VM_START_WITHLEVEL

I've got plans to improve the script to cover these functions in the future.

## Contributing

Feel free to dive in! Open an issue or submit PRs. Contributions are welcomed!

## License

This project is open-source. Tinker around and make it better!

---

Happy coding!
