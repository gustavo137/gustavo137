# C Pointers & Function Pointers — Mini Tutorial (HPC & Systems Focus)

This document provides a summary explanation of pointers, dereferencing, function pointers, callbacks, and related concepts commonly asked in HPC / systems programming interviews.

---

# 1. What is a pointer?

A pointer is a variable that **stores a memory address**, not the value itself.

```c
int x = 10;
int *p = &x;   // p stores the address of x
```

---

# 2. Dereferencing a pointer

Dereferencing means accessing the value stored at the address the pointer holds.

```c
int value = *p;  // value = 10
```

---

# 3. Arrays and pointers

Arrays automatically **decay** to pointers to their first element.

```c
int a[3] = {1, 2, 3};
int *p = a;   // same as &a[0]

printf("%d\n", *(p + 1));  // prints 2
```

Pointer arithmetic works in element-size steps, not bytes.

---

# 4. Pointer arithmetic

```c
int a[5] = {0,1,2,3,4};
int *p = a;

p++;   // moves to next array element
```

---

# 5. Double pointers (pointer to pointer)

Used for:

* dynamic multidimensional arrays
* modifying a pointer inside a function
* complex data structures (lists of lists, MPI buffers, etc.)

```c
int x = 10;
int *p = &x;
int **pp = &p;
```

---

# 6. Pointers to structs

Very common in HPC and system-level code.

```c
struct Node {
    int value;
    struct Node *next;
};

struct Node n;
struct Node *pn = &n;

pn->value = 5;
```

---

# 7. NULL pointers

Always initialize pointers.

```c
int *p = NULL;

if (p != NULL) {
    *p = 10;
}
```

---

# 8. Pointers with `const`

```c
const int *p;     // pointer to const int (cannot modify *p)
int * const p2;   // const pointer to int (pointer cannot change)
const int * const p3; // both are const
```

---

# 9. `restrict` keyword (HPC optimization)

Used in performance-critical code to inform the compiler that pointers do **not** alias.

```c
void sum(int * restrict a, int * restrict b, int * restrict c) {
    for (int i = 0; i < 1000; i++)
        c[i] = a[i] + b[i];
}
```

This enables vectorization and aggressive optimizations.

---

# 10. What is a function pointer?

A function pointer stores the **address of a function**, not data.

```c
int add(int a, int b) {
    return a + b;
}

int (*fptr)(int, int);  // declare pointer to function
fptr = add;             // assign address
```

Calling through the pointer:

```c
int result = fptr(3, 4);   // same as (*fptr)(3,4)
```

---

# 11. Why function pointers matter

They are widely used in:

* callbacks
* asynchronous I/O
* HPC and MPI libraries
* event-driven systems
* storage systems
* drivers and OS kernels
* dispatch tables
* plugin architectures

---

# 12. Callback example

```c
void apply(int (*func)(int), int x) {
    printf("%d\n", func(x));
}

int square(int a) { return a * a; }
int cube(int a)   { return a * a * a; }

apply(square, 3); // 9
apply(cube, 3);   // 27
```

---

# 13. Dispatch table (common in system-level code)

```c
int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }

int (*ops[2])(int, int) = { add, sub };

printf("%d\n", ops[0](10, 5)); // 15
printf("%d\n", ops[1](10, 5)); // 5
```

This is the basis for **virtual tables**, command dispatchers, etc.

---

# 14. Referencing vs Dereferencing a function

### Referencing

Obtaining the address of a function:

```c
fptr = add;
```

### Dereferencing

Calling the function pointed to:

```c
int result = fptr(2, 3);
```

---

# 15. Common interview questions & perfect answers

### Q1 — *What is a function pointer?*

**Answer:**
A function pointer is a variable that stores the address of a function. It allows calling a function indirectly and is used for callbacks and dynamic dispatch.

### Q2 — *How do you dereference a function pointer?*

**Answer:**
By calling it like a normal function:
`fptr(args);`

### Q3 — *Why do arrays decay to pointers?*

**Answer:**
Because in expressions, the array name is interpreted as the address of its first element.

### Q4 — *Why are function pointers useful?*

**Answer:**
They enable callbacks, modular design, event handling, and low-level system programming where behavior must be selected dynamically.

---

# 16. Summary

* A pointer stores a memory address.
* Dereferencing accesses the value at that address.
* Arrays decay to pointers.
* Function pointers store executable code addresses.
* Function pointers enable callbacks, dispatch tables, and flexible system-level designs.
* Understanding pointers is essential in HPC, storage systems, and low-level performance work.

---

