# Root-Finding Methods in Scilab

Lab Work 1, Numerical Analysis, 1CS, ESI Algiers, 2026-2027.

This project solves f(x) = 0 with three methods: NEWTON, SECANTE and OSTROWSKI. It prints the iteration tables, draws the convergence plots and compares the methods.

## Methods

NEWTON uses x(n+1) = x(n) - f(x(n)) / f'(x(n)). Its order of convergence is 2.

SECANTE uses x(n+1) = x(n) - f(x(n)) * (x(n) - x(n-1)) / (f(x(n)) - f(x(n-1))). It needs no derivative. Its order is about 1.618.

OSTROWSKI is a two-step method. First y(n) = x(n) - f(x(n)) / f'(x(n)), then x(n+1) = y(n) - (f(x(n)) / (f(x(n)) - 2 f(y(n)))) * (f(y(n)) / f'(x(n))). Its order is 4.

NEWTON and OSTROWSKI stop when |x(n+1) - x(n)| is smaller than the tolerance. SECANTE runs a fixed number of iterations.

## Files

- NEWTON.sci defines NEWTON(f, df, x0, e)
- SECANTE.sci defines SECANTE(r0, r1, fonc, n)
- OSTROWSKI.sci defines OSTROWSKI(f, df, x0, e)
- traces.sci keeps every iterate and prints the tables
- main.sce defines f, runs the experiments, prints tables and draws plots

## How to run

You need Scilab. Set Scilab's current directory to this folder, then type in the console:

    exec("main.sce", -1)

## Example

    exec("newton.sci", -1);
    exec("secante.sci", -1);
    exec("ostrowski.sci", -1);

    function y = f(x), y = x.^3 + x.^2 - 3*x - 3, endfunction
    function y = df(x), y = 3*x.^2 + 2*x - 3, endfunction

    [y, n] = NEWTON(f, df, 2, 1e-10)
    [y, n] = OSTROWSKI(f, df, 2, 1e-10)
    y = SECANTE(1, 2, f, 8)

## Test function

The lab sheet gave no function, so we used one from the course: f(x) = x^3 + x^2 - 3x - 3 on [1, 2]. Its root is sqrt(3). The starting value is 2 for NEWTON and OSTROWSKI, and 1 and 2 for SECANTE. The tolerance is 1e-10.

## Results


