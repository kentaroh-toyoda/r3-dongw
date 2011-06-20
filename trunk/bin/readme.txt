we handle the benchmarks directory 

1. compile.pl: compiles native code and r2/r3 code should always to 0x4a00??
2. compile-hermes.pl: compiles the hermes code. it should negotiate a common bss_start value to avoid data shifts
3. r.pl: we encay all files before doing a binary diff. the encap.py needs modifications in the file type fields



codefeature  encap inst.pl

TODO: psi should work for native(OK), hermes, and r2/r3

