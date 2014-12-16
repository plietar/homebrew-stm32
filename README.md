Homebrew-stm32
============
This repository contains tools for STM32 development as formulae for [Homebrew](https://github.com/mxcl/homebrew).

The formulae uses vanilla FSF sources to build the toolchain, ie not CodeSourcery or Linaro or similar.
Moreover, it does not use any prebuilt package such as those found at https://launchpad.net/gcc-arm-embedded. This makes the formula build time significant.

Current Versions
----------------
- gcc 4.9.1
- binutils 2.24.0
- newlib 2.1.0

Installing Homebrew-stm32 Formulae
--------------------------------
Just `brew tap plietar/stm32` and then `brew install <formula>`.


