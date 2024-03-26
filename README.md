# Todo App Assembly

Todo app written entirely in Intel 80386 Assembly using AT&T syntax.
It probably works only on Linux because of the system calls

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