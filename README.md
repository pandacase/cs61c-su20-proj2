# cs61c-su20-proj2

## Prologue

ucb 的教授是懂布置作业的。汇编代码和人工神经网络，两个平时完全不会互相联想到一起的东西，居然在这个项目紧密的融合在一起。融合的方法也非常简单粗暴：用纯汇编代码实现手写数字识别。听起来很癫，但实际上真的很癫。

But！实际做完后还是收获颇多的，对寄存器和内存堆栈的使用可谓到了得心应手的程度，理解也更加透彻。

**Anyway, just enjoy it.**

## Common mistakes

1. DO NOT forget to store all the **used** `t-`, `a-`, `ra` register before calling a function and restore after returning.
2. If you use **stack** to store the variable after the `Prologue` in a function, DO NOT forget to restore the value of `sp` before the `Epilogue`. 
3. Also, the value of `sp` after leaving a function SHOULD be as completely same as the state when entering the function

## Tips

1. If a function has lots of "leaves" (which means it call many other function), the value of `ra` can be store in a `s-` register and restore `ra` at the end (before `ret`). In this way you don't need to always store and restore `ra` when calling other function.
2. All the used `a-` registers can be treated as same as the previous tip.
3. In `claasify.s` the number of variables might be more than the saved register, and if you use the temporary register, you need to store and restore every once you call a function. So store some of them in stack and load it when you use it might be a good choice.
4. Comments is useful to track the vars in stack, like this:

```sh
...
  # now the data from top of stack is as follow:
  # sp +  0: row of input
  # sp +  4: col of input
  # sp +  8: row of m1
  # sp + 12: col of m1
  # sp + 16: row of m0
  # sp + 20: col of m0

...
```
