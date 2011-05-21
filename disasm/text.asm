31 40 00 39          mov #0x3900,SP
b2 40 80 5a 20 01    mov #0x5a80,&0x120
3f 40 02 00          mov #0x2,R15
0f 93                cmp 0,R15
05 24                jeq 0xa
2f 83                sub 2,R15
9f 4f 38 4a 00 11    mov 0x4a38(R15),0x1100(R15)
fb 23                jne 0x1f6
3f 40 36 00          mov #0x36,R15
0f 93                cmp 0,R15
04 24                jeq 0x8
1f 83                sub 1,R15
cf 43 02 11          mov.b 0,0x1102(R15)
fc 23                jne 0x1f8
30 40 56 46          mov #0x4656,PC
30 40 36 4a          mov #0x4a36,PC
0f 42                mov GC1,R15
32 c2                bic 8,GC1
03 43                mov 0,GC2
12 c3                bic 1,GC1
0f 10                rrc ,R15
0f 11                rra ,R15
0f 11                rra ,R15
5f f3                and.b 1,R15
30 41                mov @SP+,PC
4f 93                cmp.b 0,R15
01 24                jeq 0x2
32 d2                bis 8,GC1
30 41                mov @SP+,PC
1f 42 62 01          mov &0x162,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
02 24                jeq 0x4
1f 42 72 01          mov &0x172,R15
30 41                mov @SP+,PC
1f 42 64 01          mov &0x164,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
02 24                jeq 0x4
1f 42 74 01          mov &0x174,R15
30 41                mov @SP+,PC
1f 42 66 01          mov &0x166,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
02 24                jeq 0x4
1f 42 76 01          mov &0x176,R15
30 41                mov @SP+,PC
0f 12                push ,R15
0e 12                push ,R14
0d 12                push ,R13
0c 12                push ,R12
1f 42 2e 01          mov &0x12e,R15
12 c3                bic 1,GC1
4f 10                rrc.b.b ,R15
5f 93                cmp.b 1,R15
08 24                jeq 0x10
4f 93                cmp.b 0,R15
03 24                jeq 0x6
6f 93                cmp.b 2,R15
09 20                jne 0x12
06 3c                jmp 0xc
b0 12 4e 40          call ,#0x404e
05 3c                jmp 0xa
b0 12 5e 40          call ,#0x405e
02 3c                jmp 0x4
b0 12 6e 40          call ,#0x406e
3c 41                mov @SP+,R12
3d 41                mov @SP+,R13
3e 41                mov @SP+,R14
3f 41                mov @SP+,R15
b1 c0 f0 00 00 00    bic #0xf0,0x0(SP)
00 13                reti
0b 12                push ,R11
4b 4f                mov.b R15,R11
b0 12 34 40          call ,#0x4034
4e 4b                mov.b R11,R14
fe 93 04 11          cmp.b -1,0x1104(R14)
12 20                jne 0x24
5e 42 37 11          mov.b &0x1137,R14
4b 9e                cmp.b R14,R11
0e 24                jeq 0x1c
f2 93 36 11          cmp.b -1,&0x1136
05 20                jne 0xa
c2 4b 36 11          mov.b R11,&0x1136
c2 4b 37 11          mov.b R11,&0x1137
0d 3c                jmp 0x1a
7e f3                and.b -1,R14
ce 4b 04 11          mov.b R11,0x1104(R14)
c2 4b 37 11          mov.b R11,&0x1137
07 3c                jmp 0xe
7b 40 05 00          mov.b #0x5,R11
b0 12 46 40          call ,#0x4046
4f 4b                mov.b R11,R15
3b 41                mov @SP+,R11
30 41                mov @SP+,PC
4b 43                mov.b 0,R11
f9 3f                jn 0x1f2
1f 42 90 01          mov &0x190,R15
3d 40 90 01          mov #0x190,R13
2e 4d                mov @R13,R14
0f 9e                cmp R14,R15
02 24                jeq 0x4
0f 4e                mov R14,R15
fb 3f                jn 0x1f6
30 41                mov @SP+,PC
0b 12                push ,R11
0a 12                push ,R10
09 12                push ,R9
08 12                push ,R8
b0 12 34 40          call ,#0x4034
48 4f                mov.b R15,R8
1a 42 10 11          mov &0x1110,R10
1b 42 12 11          mov &0x1112,R11
b0 12 02 41          call ,#0x4102
09 4f                mov R15,R9
1f 42 80 01          mov &0x180,R15
5f f3                and.b 1,R15
05 24                jeq 0xa
1a 53                add 1,R10
0b 63                addc 0,R11
b0 12 02 41          call ,#0x4102
09 4f                mov R15,R9
4f 48                mov.b R8,R15
b0 12 46 40          call ,#0x4046
0f 49                mov R9,R15
12 c3                bic 1,GC1
0f 10                rrc ,R15
0f 11                rra ,R15
0f 11                rra ,R15
0f 11                rra ,R15
0f 11                rra ,R15
0c 4f                mov R15,R12
0d 43                mov 0,R13
0e 4a                mov R10,R14
0f 4b                mov R11,R15
4f ee                xor.b R14,R15
0f ee                xor R14,R15
8f 10                swpb ,R15
7e f3                and.b -1,R14
8e 10                swpb ,R14
0e 5e                add R14,R14
0f 6f                addc R15,R15
0e 5e                add R14,R14
0f 6f                addc R15,R15
0e 5e                add R14,R14
0f 6f                addc R15,R15
0e dc                bis R12,R14
0f dd                bis R13,R15
38 41                mov @SP+,R8
39 41                mov @SP+,R9
3a 41                mov @SP+,R10
3b 41                mov @SP+,R11
30 41                mov @SP+,PC
0b 12                push ,R11
0a 12                push ,R10
09 12                push ,R9
08 12                push ,R8
b0 12 16 41          call ,#0x4116
0a 4e                mov R14,R10
0b 4f                mov R15,R11
1e 42 0c 11          mov &0x110c,R14
1f 42 0e 11          mov &0x110e,R15
0c 4e                mov R14,R12
0d 4f                mov R15,R13
1c 52 08 11          add &0x1108,R12
1d 62 0a 11          addc &0x110a,R13
08 4a                mov R10,R8
09 4b                mov R11,R9
08 8e                sub R14,R8
09 7f                subc R15,R9
0b 28                jnc 0x16
08 4c                mov R12,R8
09 4d                mov R13,R9
08 8e                sub R14,R8
09 7f                subc R15,R9
10 28                jnc 0x20
0e 4a                mov R10,R14
0f 4b                mov R11,R15
0e 8c                sub R12,R14
0f 7d                subc R13,R15
2b 2c                jc 0x56
0a 3c                jmp 0x14
08 4c                mov R12,R8
09 4d                mov R13,R9
08 8e                sub R14,R8
09 7f                subc R15,R9
25 2c                jc 0x4a
0e 4a                mov R10,R14
0f 4b                mov R11,R15
0e 8c                sub R12,R14
0f 7d                subc R13,R15
20 2c                jc 0x40
0e 4c                mov R12,R14
0f 4d                mov R13,R15
0e 8a                sub R10,R14
0f 7b                subc R11,R15
38 40 00 04          mov #0x400,R8
09 43                mov 0,R9
08 8e                sub R14,R8
09 7f                subc R15,R9
18 2c                jc 0x30
0c 4a                mov R10,R12
0d 4b                mov R11,R13
3c 50 00 04          add #0x400,R12
0d 63                addc 0,R13
82 4c 0c 11          mov R12,&0x110c
82 4d 0e 11          mov R13,&0x110e
0c 4e                mov R14,R12
0d 4f                mov R15,R13
3c 50 00 fc          add #0xfc00,R12
3d 63                addc -1,R13
82 4c 08 11          mov R12,&0x1108
82 4d 0a 11          mov R13,&0x110a
3e 40 00 04          mov #0x400,R14
0f 43                mov 0,R15
0a 3c                jmp 0x14
0e 43                mov 0,R14
0f 43                mov 0,R15
82 4c 0c 11          mov R12,&0x110c
82 4d 0e 11          mov R13,&0x110e
82 43 08 11          mov 0,&0x1108
82 43 0a 11          mov 0,&0x110a
0f 4e                mov R14,R15
0f 5f                add R15,R15
0f 5f                add R15,R15
0f 5f                add R15,R15
0f 5f                add R15,R15
08 4f                mov R15,R8
08 58                add R8,R8
b0 12 02 41          call ,#0x4102
0e 4a                mov R10,R14
0e 5e                add R14,R14
0e 5e                add R14,R14
0e 5e                add R14,R14
0e 5e                add R14,R14
0e 5e                add R14,R14
0d 4f                mov R15,R13
0d 8e                sub R14,R13
0d 98                cmp R8,R13
06 28                jnc 0xc
b0 12 02 41          call ,#0x4102
2f 53                add 2,R15
82 4f 92 01          mov R15,&0x192
0d 3c                jmp 0x1a
08 8d                sub R13,R8
38 90 03 00          cmp #0x3,R8
06 2c                jc 0xc
b0 12 02 41          call ,#0x4102
2f 53                add 2,R15
82 4f 92 01          mov R15,&0x192
03 3c                jmp 0x6
08 5f                add R15,R8
82 48 92 01          mov R8,&0x192
3f 40 82 01          mov #0x182,R15
9f c3 00 00          bic 1,0x0(R15)
bf d0 10 00 00 00    bis #0x10,0x0(R15)
38 41                mov @SP+,R8
39 41                mov @SP+,R9
3a 41                mov @SP+,R10
3b 41                mov @SP+,R11
30 41                mov @SP+,PC
7f 92                cmp.b 8,R15
5a 2c                jne 0xb4
7f f3                and.b -1,R15
0f 5f                add R15,R15
10 4f a0 42          mov 0x42a0(R15),PC
b0 42 e4 42          mov 8,0x42e4
f4 42 04 43          mov.b 8,0x4304(R4)
14 43                mov 1,R4
24 43                mov 2,R4
34 43                mov -1,R4
44 43                mov.b 0,R4
1f 42 82 01          mov &0x182,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
03 24                jeq 0x6
1f 42 92 01          mov &0x192,R15
30 41                mov @SP+,PC
b2 f0 ef ff 82 01    and #0xffef,&0x182
0e 43                mov 0,R14
0f 43                mov 0,R15
82 9e 08 11          cmp R14,&0x1108
07 20                jne 0xe
82 9f 0a 11          cmp R15,&0x110a
04 20                jne 0x8
4f 43                mov.b 0,R15
b0 12 bc 40          call ,#0x40bc
30 41                mov @SP+,PC
b0 12 84 41          call ,#0x4184
30 41                mov @SP+,PC
1f 42 84 01          mov &0x184,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
2f 24                jeq 0x5e
1f 42 94 01          mov &0x194,R15
30 41                mov @SP+,PC
1f 42 86 01          mov &0x186,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
27 24                jeq 0x4e
1f 42 96 01          mov &0x196,R15
30 41                mov @SP+,PC
1f 42 88 01          mov &0x188,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
1f 24                jeq 0x3e
1f 42 98 01          mov &0x198,R15
30 41                mov @SP+,PC
1f 42 8a 01          mov &0x18a,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
17 24                jeq 0x2e
1f 42 9a 01          mov &0x19a,R15
30 41                mov @SP+,PC
1f 42 8c 01          mov &0x18c,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
0f 24                jeq 0x1e
1f 42 9c 01          mov &0x19c,R15
30 41                mov @SP+,PC
1f 42 8e 01          mov &0x18e,R15
8f 10                swpb ,R15
5f f3                and.b 1,R15
07 24                jeq 0xe
1f 42 9e 01          mov &0x19e,R15
30 41                mov @SP+,PC
92 53 10 11          add 1,&0x1110
82 63 12 11          addc 0,&0x1112
30 41                mov @SP+,PC
0f 12                push ,R15
0e 12                push ,R14
0d 12                push ,R13
0c 12                push ,R12
4f 43                mov.b 0,R15
b0 12 94 42          call ,#0x4294
3c 41                mov @SP+,R12
3d 41                mov @SP+,R13
3e 41                mov @SP+,R14
3f 41                mov @SP+,R15
b1 c0 f0 00 00 00    bic #0xf0,0x0(SP)
00 13                reti
0f 12                push ,R15
0e 12                push ,R14
0d 12                push ,R13
0c 12                push ,R12
1f 42 1e 01          mov &0x11e,R15
12 c3                bic 1,GC1
4f 10                rrc.b.b ,R15
b0 12 94 42          call ,#0x4294
3c 41                mov @SP+,R12
3d 41                mov @SP+,R13
3e 41                mov @SP+,R14
3f 41                mov @SP+,R15
b1 c0 f0 00 00 00    bic #0xf0,0x0(SP)
00 13                reti
0d 4f                mov R15,R13
8d 10                swpb ,R13
7d f0 07 00          and.b #0x7,R13
5e 42 57 00          mov.b &0x57,R14
7e f0 f8 ff          and.b #0xfff8,R14
4d de                bis.b R14,R13
c2 4d 57 00          mov.b R13,&0x57
c2 4f 56 00          mov.b R15,&0x56
30 41                mov @SP+,PC
4f 93                cmp.b 0,R15
03 24                jeq 0x6
e2 d3 19 00          bis.b 2,&0x19
02 3c                jmp 0x4
e2 c3 19 00          bic.b 2,&0x19
f2 d2 19 00          bis.b 8,&0x19
f2 c2 19 00          bic.b 8,&0x19
30 41                mov @SP+,PC
0b 12                push ,R11
0a 12                push ,R10
09 12                push ,R9
08 12                push ,R8
07 12                push ,R7
06 12                push ,R6
05 12                push ,R5
04 12                push ,R4
0a 4e                mov R14,R10
0b 4f                mov R15,R11
3f 40 14 11          mov #0x1114,R15
4c 43                mov.b 0,R12
04 4f                mov R15,R4
55 4f 08 00          mov.b 0x8(R15),R5
4e 45                mov.b R5,R14
6e f3                and.b 2,R14
3a 24                jeq 0x74
38 4f                mov @R15+,R8
39 4f                mov @R15+,R9
2f 82                sub 4,R15
16 4f 04 00          mov 0x4(R15),R6
17 4f 06 00          mov 0x6(R15),R7
0d 4a                mov R10,R13
0e 4b                mov R11,R14
0d 88                sub R8,R13
0e 79                subc R9,R14
0d 86                sub R6,R13
0e 77                subc R7,R14
2c 28                jnc 0x58
55 f3                and.b 1,R5
03 24                jeq 0x6
ef c3 08 00          bic.b 2,0x8(R15)
08 3c                jmp 0x10
0e 46                mov R6,R14
0f 47                mov R7,R15
0e 58                add R8,R14
0f 69                addc R9,R15
84 4e 00 00          mov R14,0x0(R4)
84 4f 02 00          mov R15,0x2(R4)
5c 93                cmp.b 1,R12
0d 24                jeq 0x1a
4c 93                cmp.b 0,R12
03 24                jeq 0x6
6c 93                cmp.b 2,R12
1f 20                jne 0x3e
10 3c                jmp 0x20
b0 12 34 40          call ,#0x4034
f2 e0 10 00 31 00    xor.b #0x10,&0x31
b0 12 46 40          call ,#0x4046
16 3c                jmp 0x2c
b0 12 34 40          call ,#0x4034
f2 e0 20 00 31 00    xor.b #0x20,&0x31
b0 12 46 40          call ,#0x4046
0e 3c                jmp 0x1c
b0 12 34 40          call ,#0x4034
f2 e0 40 00 31 00    xor.b #0x40,&0x31
b0 12 46 40          call ,#0x4046
06 3c                jmp 0xc
5c 53                add.b 1,R12
3f 50 0a 00          add #0xa,R15
7c 90 03 00          cmp.b #0x3,R12
ba 23                jne 0x174
5f 43                mov.b 1,R15
b0 12 bc 40          call ,#0x40bc
34 41                mov @SP+,R4
35 41                mov @SP+,R5
36 41                mov @SP+,R6
37 41                mov @SP+,R7
38 41                mov @SP+,R8
39 41                mov @SP+,R9
3a 41                mov @SP+,R10
3b 41                mov @SP+,R11
30 41                mov @SP+,PC
0b 12                push ,R11
0a 12                push ,R10
09 12                push ,R9
08 12                push ,R8
07 12                push ,R7
08 4e                mov R14,R8
09 4f                mov R15,R9
0a 4c                mov R12,R10
0b 4d                mov R13,R11
b0 12 34 40          call ,#0x4034
47 4f                mov.b R15,R7
82 48 0c 11          mov R8,&0x110c
82 49 0e 11          mov R9,&0x110e
82 4a 08 11          mov R10,&0x1108
82 4b 0a 11          mov R11,&0x110a
b0 12 84 41          call ,#0x4184
4f 47                mov.b R7,R15
b0 12 46 40          call ,#0x4046
37 41                mov @SP+,R7
38 41                mov @SP+,R8
39 41                mov @SP+,R9
3a 41                mov @SP+,R10
3b 41                mov @SP+,R11
30 41                mov @SP+,PC
0b 12                push ,R11
0a 12                push ,R10
09 12                push ,R9
08 12                push ,R8
07 12                push ,R7
06 12                push ,R6
05 12                push ,R5
04 12                push ,R4
b0 12 16 41          call ,#0x4116
09 4e                mov R14,R9
0a 4f                mov R15,R10
b2 f0 ef ff 82 01    and #0xffef,&0x182
3f 40 14 11          mov #0x1114,R15
05 4f                mov R15,R5
35 50 1e 00          add #0x1e,R5
44 43                mov.b 0,R4
37 43                mov -1,R7
38 40 ff 7f          mov #0x7fff,R8
46 44                mov.b R4,R6
0d 4f                mov R15,R13
5f 4d 08 00          mov.b 0x8(R13),R15
6f f3                and.b 2,R15
4f 96                cmp.b R6,R15
13 24                jeq 0x26
0e 49                mov R9,R14
0f 4a                mov R10,R15
3e 8d                sub @R13+,R14
3f 7d                subc @R13+,R15
2d 82                sub 4,R13
1b 4d 04 00          mov 0x4(R13),R11
1c 4d 06 00          mov 0x6(R13),R12
0b 8e                sub R14,R11
0c 7f                subc R15,R12
0e 4b                mov R11,R14
0f 4c                mov R12,R15
0b 87                sub R7,R11
0c 78                subc R8,R12
03 34                jge 0x6
07 4e                mov R14,R7
08 4f                mov R15,R8
54 43                mov.b 1,R4
3d 50 0a 00          add #0xa,R13
0d 95                cmp R5,R13
e4 23                jne 0x1c8
44 93                cmp.b 0,R4
16 24                jeq 0x2c
0e 43                mov 0,R14
0f 43                mov 0,R15
0e 87                sub R7,R14
0f 78                subc R8,R15
05 38                jl 0xa
0e 49                mov R9,R14
0f 4a                mov R10,R15
b0 12 c4 43          call ,#0x43c4
0c 3c                jmp 0x18
82 47 32 11          mov R7,&0x1132
82 48 34 11          mov R8,&0x1134
d2 43 06 11          mov.b 1,&0x1106
0c 47                mov R7,R12
0d 48                mov R8,R13
0e 49                mov R9,R14
0f 4a                mov R10,R15
b0 12 82 44          call ,#0x4482
34 41                mov @SP+,R4
35 41                mov @SP+,R5
36 41                mov @SP+,R6
37 41                mov @SP+,R7
38 41                mov @SP+,R8
39 41                mov @SP+,R9
3a 41                mov @SP+,R10
3b 41                mov @SP+,R11
30 41                mov @SP+,PC
0b 12                push ,R11
0a 12                push ,R10
09 12                push ,R9
08 12                push ,R8
c2 93 06 11          cmp.b 0,&0x1106
1c 20                jne 0x38
1a 42 32 11          mov &0x1132,R10
1b 42 34 11          mov &0x1134,R11
b0 12 34 40          call ,#0x4034
18 42 08 11          mov &0x1108,R8
19 42 0a 11          mov &0x110a,R9
18 52 0c 11          add &0x110c,R8
19 62 0e 11          addc &0x110e,R9
b0 12 46 40          call ,#0x4046
82 4a 32 11          mov R10,&0x1132
82 4b 34 11          mov R11,&0x1134
c2 43 06 11          mov.b 0,&0x1106
0c 4a                mov R10,R12
0d 4b                mov R11,R13
0e 48                mov R8,R14
0f 49                mov R9,R15
b0 12 82 44          call ,#0x4482
b0 12 16 41          call ,#0x4116
b0 12 c4 43          call ,#0x43c4
38 41                mov @SP+,R8
39 41                mov @SP+,R9
3a 41                mov @SP+,R10
3b 41                mov @SP+,R11
30 41                mov @SP+,PC
5f 42 36 11          mov.b &0x1136,R15
7f 93                cmp.b -1,R15
02 20                jne 0x4
4f 43                mov.b 0,R15
30 41                mov @SP+,PC
4d 4f                mov.b R15,R13
0e 4d                mov R13,R14
3e 50 04 11          add #0x1104,R14
6c 4e                mov.b @R14,R12
c2 4c 36 11          mov.b R12,&0x1136
7c 93                cmp.b -1,R12
02 20                jne 0x4
f2 43 37 11          mov.b -1,&0x1137
fd 43 04 11          mov.b -1,0x1104(R13)
4f 93                cmp.b 0,R15
04 24                jeq 0x8
5f 93                cmp.b 1,R15
06 24                jeq 0xc
5f 43                mov.b 1,R15
30 41                mov @SP+,PC
b0 12 6e 45          call ,#0x456e
5f 43                mov.b 1,R15
30 41                mov @SP+,PC
b0 12 c0 44          call ,#0x44c0
5f 43                mov.b 1,R15
30 41                mov @SP+,PC
0b 12                push ,R11
0a 12                push ,R10
09 12                push ,R9
4b 4f                mov.b R15,R11
09 4d                mov R13,R9
0a 4e                mov R14,R10
b0 12 16 41          call ,#0x4116
4c 4b                mov.b R11,R12
0c 5c                add R12,R12
0c 5c                add R12,R12
7b f3                and.b -1,R11
0b 5b                add R11,R11
0c 5b                add R11,R12
0c 5b                add R11,R12
0c 5b                add R11,R12
3c 50 14 11          add #0x1114,R12
8c 4e 00 00          mov R14,0x0(R12)
8c 4f 02 00          mov R15,0x2(R12)
8c 49 04 00          mov R9,0x4(R12)
8c 4a 06 00          mov R10,0x6(R12)
5f 4c 08 00          mov.b 0x8(R12),R15
5f c3                bic.b 1,R15
6f d3                bis.b 2,R15
cc 4f 08 00          mov.b R15,0x8(R12)
5f 43                mov.b 1,R15
b0 12 bc 40          call ,#0x40bc
39 41                mov @SP+,R9
3a 41                mov @SP+,R10
3b 41                mov @SP+,R11
30 41                mov @SP+,PC
31 40 fe 38          mov #0x38fe,SP
b0 12 34 40          call ,#0x4034
46 4f                mov.b R15,R6
3e 40 04 11          mov #0x1104,R14
fe 43 00 00          mov.b -1,0x0(R14)
fe 43 01 00          mov.b -1,0x1(R14)
f2 43 36 11          mov.b -1,&0x1136
f2 43 37 11          mov.b -1,&0x1137
a2 42 60 01          mov 4,&0x160
82 43 2e 01          mov 0,&0x12e
a2 42 80 01          mov 4,&0x180
82 43 1e 01          mov 0,&0x11e
b2 40 20 02 60 01    mov #0x220,&0x160
b2 40 20 01 80 01    mov #0x120,&0x180
f2 40 84 ff 57 00    mov.b #0xff84,&0x57
c2 43 58 00          mov.b 0,&0x58
b2 40 00 40 82 01    mov #0x4000,&0x182
0a 43                mov 0,R10
38 40 00 08          mov #0x800,R8
09 4a                mov R10,R9
07 4a                mov R10,R7
55 43                mov.b 1,R5
34 40 0c 00          mov #0xc,R4
0b 48                mov R8,R11
0b d9                bis R9,R11
0f 4b                mov R11,R15
b0 12 90 43          call ,#0x4390
0c 47                mov R7,R12
4f 45                mov.b R5,R15
1e 42 90 01          mov &0x190,R14
3e 52                add 8,R14
82 4e 92 01          mov R14,&0x192
92 c3 82 01          bic 1,&0x182
1e 42 82 01          mov &0x182,R14
1e f3                and 1,R14
0e 97                cmp R7,R14
fb 27                jne 0x1f6
1e 42 70 01          mov &0x170,R14
4f 93                cmp.b 0,R15
03 24                jeq 0x6
7f 53                add.b -1,R15
0c 4e                mov R14,R12
ed 3f                jn 0x1da
0e 8c                sub R12,R14
3f 40 00 04          mov #0x400,R15
0f 9e                cmp R14,R15
01 2c                jc 0x2
0b 49                mov R9,R11
08 11                rra ,R8
1a 53                add 1,R10
0a 94                cmp R4,R10
02 24                jeq 0x4
09 4b                mov R11,R9
da 3f                jn 0x1b4
0d 4b                mov R11,R13
3d f0 e0 00          and #0xe0,R13
3d 90 e0 00          cmp #0xe0,R13
02 20                jne 0x4
3b f0 e0 ff          and #0xffe0,R11
0f 4b                mov R11,R15
b0 12 90 43          call ,#0x4390
5e 42 57 00          mov.b &0x57,R14
7e f0 07 00          and.b #0x7,R14
7e d0 80 ff          bis.b #0xff80,R14
c2 4e 57 00          mov.b R14,&0x57
e2 42 58 00          mov.b 4,&0x58
e2 c3 00 00          bic.b 2,&0x0
82 43 70 01          mov 0,&0x170
b2 40 02 02 60 01    mov #0x202,&0x160
82 43 90 01          mov 0,&0x190
b2 40 02 01 80 01    mov #0x102,&0x180
1e 42 60 01          mov &0x160,R14
3e f0 cf ff          and #0xffcf,R14
3e d0 20 00          bis #0x20,R14
82 4e 60 01          mov R14,&0x160
1e 42 80 01          mov &0x180,R14
3e f0 cf ff          and #0xffcf,R14
3e d0 20 00          bis #0x20,R14
82 4e 80 01          mov R14,&0x180
c2 43 26 00          mov.b 0,&0x26
c2 43 2e 00          mov.b 0,&0x2e
c2 43 1b 00          mov.b 0,&0x1b
c2 43 1f 00          mov.b 0,&0x1f
c2 43 33 00          mov.b 0,&0x33
c2 43 37 00          mov.b 0,&0x37
c2 43 21 00          mov.b 0,&0x21
f2 40 e0 ff 22 00    mov.b #0xffe0,&0x22
f2 40 30 00 29 00    mov.b #0x30,&0x29
f2 40 7b 00 2a 00    mov.b #0x7b,&0x2a
c2 43 19 00          mov.b 0,&0x19
f2 40 f1 ff 1a 00    mov.b #0xfff1,&0x1a
f2 40 dd ff 1d 00    mov.b #0xffdd,&0x1d
f2 40 fd ff 1e 00    mov.b #0xfffd,&0x1e
f2 43 31 00          mov.b -1,&0x31
f2 43 32 00          mov.b -1,&0x32
c2 43 35 00          mov.b 0,&0x35
f2 43 36 00          mov.b -1,&0x36
c2 43 25 00          mov.b 0,&0x25
c2 43 2d 00          mov.b 0,&0x2d
1e 42 70 01          mov &0x170,R14
3d 40 00 28          mov #0x2800,R13
1f 42 70 01          mov &0x170,R15
0f 8e                sub R14,R15
0d 9f                cmp R15,R13
fb 2f                jne 0x1f6
e2 d3 1a 00          bis.b 2,&0x1a
f2 d2 1a 00          bis.b 8,&0x1a
f2 d0 80 ff 1e 00    bis.b #0xff80,&0x1e
f2 d0 10 00 1e 00    bis.b #0x10,&0x1e
f2 d0 80 ff 1d 00    bis.b #0xff80,&0x1d
f2 d0 10 00 1d 00    bis.b #0x10,&0x1d
03 43                mov 0,GC2
03 43                mov 0,GC2
f2 f0 ef ff 1d 00    and.b #0xffef,&0x1d
f2 c2 19 00          bic.b 8,&0x19
5b 43                mov.b 1,R11
4f 4b                mov.b R11,R15
b0 12 ac 43          call ,#0x43ac
4f 43                mov.b 0,R15
b0 12 ac 43          call ,#0x43ac
4f 4b                mov.b R11,R15
b0 12 ac 43          call ,#0x43ac
4f 4b                mov.b R11,R15
b0 12 ac 43          call ,#0x43ac
4f 4b                mov.b R11,R15
b0 12 ac 43          call ,#0x43ac
4f 43                mov.b 0,R15
b0 12 ac 43          call ,#0x43ac
4f 43                mov.b 0,R15
b0 12 ac 43          call ,#0x43ac
4f 4b                mov.b R11,R15
b0 12 ac 43          call ,#0x43ac
f2 d0 10 00 1d 00    bis.b #0x10,&0x1d
f2 d2 19 00          bis.b 8,&0x19
e2 d3 19 00          bis.b 2,&0x19
3e 40 32 00          mov #0x32,R14
fe d0 10 00 00 00    bis.b #0x10,0x0(R14)
fe d0 20 00 00 00    bis.b #0x20,0x0(R14)
fe d0 40 00 00 00    bis.b #0x40,0x0(R14)
3e 53                add -1,R14
fe d0 10 00 00 00    bis.b #0x10,0x0(R14)
fe d0 20 00 00 00    bis.b #0x20,0x0(R14)
fe d0 40 00 00 00    bis.b #0x40,0x0(R14)
4b 43                mov.b 0,R11
b0 12 c6 45          call ,#0x45c6
4f 9b                cmp.b R11,R15
fc 23                jne 0x1f8
3e 40 82 01          mov #0x182,R14
be f0 ef ff 00 00    and #0xffef,0x0(R14)
be 40 00 40 00 00    mov #0x4000,0x0(R14)
4b 43                mov.b 0,R11
b0 12 c6 45          call ,#0x45c6
4f 9b                cmp.b R11,R15
fc 23                jne 0x1f8
4f 46                mov.b R6,R15
b0 12 46 40          call ,#0x4046
32 d2                bis 8,GC1
3d 40 fa 00          mov #0xfa,R13
0e 43                mov 0,R14
4f 43                mov.b 0,R15
b0 12 08 46          call ,#0x4608
3d 40 f4 01          mov #0x1f4,R13
0e 43                mov 0,R14
5f 43                mov.b 1,R15
b0 12 08 46          call ,#0x4608
3d 40 e8 03          mov #0x3e8,R13
0e 43                mov 0,R14
6f 43                mov.b 2,R15
b0 12 08 46          call ,#0x4608
79 43                mov.b -1,R9
48 43                mov.b 0,R8
0a 43                mov 0,R10
67 42                mov.b 4,R7
66 43                mov.b 2,R6
34 40 00 02          mov #0x200,R4
55 43                mov.b 1,R5
b0 12 34 40          call ,#0x4034
80 3c                jn 0x100
1e 42 62 01          mov &0x162,R14
3e f0 10 00          and #0x10,R14
0e 9a                cmp R10,R14
0c 20                jne 0x18
1e 42 64 01          mov &0x164,R14
3e f0 10 00          and #0x10,R14
0e 9a                cmp R10,R14
06 20                jne 0xc
1e 42 66 01          mov &0x166,R14
3e f0 10 00          and #0x10,R14
0e 9a                cmp R10,R14
06 24                jeq 0xc
1e 42 60 01          mov &0x160,R14
3e f0 00 03          and #0x300,R14
0e 94                cmp R4,R14
37 24                jeq 0x6e
5e 42 04 00          mov.b &0x4,R14
7e f0 c0 ff          and.b #0xffc0,R14
4e 98                cmp.b R8,R14
06 24                jeq 0xc
5e 42 71 00          mov.b &0x71,R14
3e f0 20 00          and #0x20,R14
0e 9a                cmp R10,R14
2b 20                jne 0x56
5e 42 05 00          mov.b &0x5,R14
3e f0 30 00          and #0x30,R14
0e 9a                cmp R10,R14
06 24                jeq 0xc
5e 42 79 00          mov.b &0x79,R14
3e f0 20 00          and #0x20,R14
0e 9a                cmp R10,R14
1f 20                jne 0x3e
5e 42 70 00          mov.b &0x70,R14
1e f3                and 1,R14
0e 9a                cmp R10,R14
17 24                jeq 0x2e
5e 42 71 00          mov.b &0x71,R14
3e f0 20 00          and #0x20,R14
0e 9a                cmp R10,R14
11 24                jeq 0x22
5e 42 72 00          mov.b &0x72,R14
3e f0 20 00          and #0x20,R14
0e 9a                cmp R10,R14
0b 24                jeq 0x16
5e 42 70 00          mov.b &0x70,R14
2e f2                and 4,R14
0e 9a                cmp R10,R14
06 24                jeq 0xc
5e 42 70 00          mov.b &0x70,R14
3e f0 20 00          and #0x20,R14
0e 9a                cmp R10,R14
03 20                jne 0x6
7e 40 05 00          mov.b #0x5,R14
01 3c                jmp 0x2
4e 46                mov.b R6,R14
1d 42 a0 01          mov &0x1a0,R13
3d f0 10 00          and #0x10,R13
0d 9a                cmp R10,R13
1a 24                jeq 0x34
1d 42 a2 01          mov &0x1a2,R13
3d f0 10 00          and #0x10,R13
0d 9a                cmp R10,R13
07 24                jeq 0xe
1e 42 a2 01          mov &0x1a2,R14
3e f2                and 8,R14
0e 9a                cmp R10,R14
0e 20                jne 0x1c
4e 48                mov.b R8,R14
0d 3c                jmp 0x1a
1d 42 a2 01          mov &0x1a2,R13
3d f0 00 04          and #0x400,R13
0d 9a                cmp R10,R13
07 24                jeq 0xe
1d 42 60 01          mov &0x160,R13
3d f0 00 03          and #0x300,R13
0d 94                cmp R4,R13
01 20                jne 0x2
4e 46                mov.b R6,R14
47 9e                cmp.b R14,R7
01 2c                jc 0x2
4e 47                mov.b R7,R14
c2 4e 02 11          mov.b R14,&0x1102
5e 42 02 11          mov.b &0x1102,R14
0e 5e                add R14,R14
1e 4e 2a 4a          mov 0x4a2a(R14),R14
3e d2                bis 8,R14
81 4e 00 00          mov R14,0x0(SP)
22 d1                bis @SP,GC1
32 c2                bic 8,GC1
03 43                mov 0,GC2
5b 42 36 11          mov.b &0x1136,R11
4b 99                cmp.b R9,R11
14 24                jeq 0x28
4d 4b                mov.b R11,R13
0e 4d                mov R13,R14
3e 50 04 11          add #0x1104,R14
6c 4e                mov.b @R14,R12
c2 4c 36 11          mov.b R12,&0x1136
4c 99                cmp.b R9,R12
02 20                jne 0x4
c2 49 37 11          mov.b R9,&0x1137
fd 43 04 11          mov.b -1,0x1104(R13)
b0 12 46 40          call ,#0x4046
4b 98                cmp.b R8,R11
07 24                jeq 0xe
4b 95                cmp.b R5,R11
66 23                jne 0xcc
07 3c                jmp 0xe
c2 98 00 11          cmp.b R8,&0x1100
65 23                jne 0xca
d9 3f                jn 0x1b2
b0 12 6e 45          call ,#0x456e
5e 3f                jn 0xbc
b0 12 c0 44          call ,#0x44c0
5b 3f                jn 0xb6
0f 12                push ,R15
0e 12                push ,R14
0d 12                push ,R13
0c 12                push ,R12
b0 12 4e 40          call ,#0x404e
3c 41                mov @SP+,R12
3d 41                mov @SP+,R13
3e 41                mov @SP+,R14
3f 41                mov @SP+,R15
b1 c0 f0 00 00 00    bic #0xf0,0x0(SP)
00 13                reti
mn err 00 00               
00 00                 ,PC
mn err 10 00               
10 00 50 00           ,0x50
mn err 90 00               
90 00 d0 00           ,0xd0
mn err f0 00               
f0 00 00 13          .b ,#0x1300
mn err 00 00               
00 00                 ,PC
mn err 00 00               
00 00                 ,PC
mn err 00 00               
00 00                 ,PC
mn err 00 00               
00 00                 ,PC
