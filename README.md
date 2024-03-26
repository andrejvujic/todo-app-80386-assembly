# Todo App Assembly

Todo App written entirely in 80386 Assembly using AT&T syntax. This project was heavily insipired by <a href="https://youtu.be/WnBXLmKk_qw?si=jBxjggwA2fn_uian">Tscoding's implementation in FASM</a>. Take a look at it <a href="https://github.com/tsoding/todo.asm">here</a>.

The implementation isn't perfect yet and I will be working on improving it.

# How to run?

If you are using x86_64, to compile this project you will need `gcc-multilib`. You can install it using:

```
sudo apt-get install -y gcc-multilib
```

To compile the code use `gcc` with the `-m32` flag:

```
gcc -m32 todo.S
```

And finally run it:

```
./a.out
```

# Resources

You can view all x86 system calls <a href="https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#x86-32_bit">here</a>.