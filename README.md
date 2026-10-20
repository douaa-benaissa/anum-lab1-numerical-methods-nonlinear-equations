# Root-Finding Methods in Scilab: Newton, Secant, Ostrowski

Lab Work 1, Numerical Analysis, 1CS, ESI Algiers, 2026-2027.

This project solves `f(x) = 0` with three iterative methods (`NEWTON`, `SECANTE`, `OSTROWSKI`). For each one it prints the iteration table, estimates the order of convergence (ACOC), draws semi-log convergence plots, and compares the methods on accuracy, cost and efficiency.

## Contents

1. [Methods](#methods)
2. [Project structure](#project-structure)
3. [Requirements and how to run](#requirements-and-how-to-run)
4. [Function signatures and usage example](#function-signatures-and-usage-example)
5. [Test problem](#test-problem)
6. [What main.sce does](#what-mainsce-does)
7. [Results](#results)
8. [Remarks and limitations](#remarks-and-limitations)

## Methods

**NEWTON** (order 2, needs `f` and `f'`):

    x(n+1) = x(n) - f(x(n)) / f'(x(n))

**SECANTE** (order (1+sqrt(5))/2 ≈ 1.618, no derivative needed):

    x(n+1) = x(n) - f(x(n)) * (x(n) - x(n-1)) / (f(x(n)) - f(x(n-1)))

**OSTROWSKI** (two-step, order 4, needs `f` and `f'`):

    y(n)   = x(n) - f(x(n)) / f'(x(n))
    x(n+1) = y(n) - ( f(x(n)) / (f(x(n)) - 2 f(y(n))) ) * ( f(y(n)) / f'(x(n)) )

**Stopping rule.** `NEWTON` and `OSTROWSKI` stop when `|x(n+1) - x(n)| < e`, with a safety limit of 100 iterations. `SECANTE` takes the number of iterations `n` as an input. In `main.sce`, the smallest `n` satisfying the same test `|x(n) - x(n-1)| < e` is searched first, so all three methods use the same criterion.

## Project structure

| File | Role |
|---|---|
| `NEWTON.sci` | `[y, n] = NEWTON(f, df, x0, e)` |
| `SECANTE.sci` | `y = SECANTE(r0, r1, fonc, n)` |
| `OSTROWSKI.sci` | `[y, n] = OSTROWSKI(f, df, x0, e)` |
| `NEWTON_rec.sci`, `SECANTE_rec.sci`, `OSTROWSKI_rec.sci` | Same methods, but they keep every iterate. Each returns a record matrix `[n, xn, f(xn), dn]` |
| `Approxim_Comp_Order_Conv.sci` | Computes the ACOC table `[n, xn, dn, rn, ln(rn), pn]` from a record matrix |
| `Display_fun.sci` | `Display_record` and `Display_ACOC`: formatted table printing (`-` means no value) |
| `plot_semilog.sci` | `Plot_convergence`: semi-log plots of `f(xn)` or `dn` for the three methods |
| `main.sce` | Defines the test problem, runs everything, prints tables, saves plots, compares methods |
| `results/` | Created automatically; contains the saved plots |

## Requirements and how to run

You need [Scilab](https://www.scilab.org/). All files must stay in the same folder.

1. Set Scilab's current directory to this folder.
2. In the console, type:

```scilab
exec("main.sce", -1)
```

`main.sce` loads every `.sci` file by itself, using the folder of the script, so nothing else has to be loaded by hand. The plots are saved to `results/plot_residual.png` and `results/plot_step.png`. If the graphics cannot be created (for example in a console without a display), the plot step is skipped with a message and the rest of the output is unaffected.

## Function signatures and usage example

| Function | Inputs | Outputs |
|---|---|---|
| `NEWTON(f, df, x0, e)` | function, derivative, start point, tolerance | `y` = approximate root, `n` = iterations |
| `OSTROWSKI(f, df, x0, e)` | same | `y`, `n` |
| `SECANTE(r0, r1, fonc, n)` | two start points, function, number of iterations | `y` = approximate root |

Standalone use (file names are case-sensitive on Linux and macOS):

```scilab
exec("NEWTON.sci", -1);
exec("SECANTE.sci", -1);
exec("OSTROWSKI.sci", -1);

function y = f(x), y = x.^3 + x.^2 - 3*x - 3, endfunction
function y = df(x), y = 3*x.^2 + 2*x - 3, endfunction

[y, n] = NEWTON(f, df, 2, 1e-10)
[y, n] = OSTROWSKI(f, df, 2, 1e-10)
y = SECANTE(1, 2, f, 8)
```

Error handling: `NEWTON` and `OSTROWSKI` stop with an error if the derivative is zero, and print a warning if the tolerance is not reached within 100 iterations. `SECANTE` stops early if `f(x(n)) = f(x(n-1))`.

## Test problem

The lab sheet gives no function, so we used a course example:

    f(x) = x^3 + x^2 - 3x - 3   on [1, 2],   f'(x) = 3x^2 + 2x - 3

The exact root is `sqrt(3) = 1.732050807568877`. It is used only to measure the true error. Parameters: `x0 = 2` for NEWTON and OSTROWSKI, `r0 = 1` and `r1 = 2` for SECANTE, tolerance `e = 1e-10`.

## What main.sce does

Each step matches a part of the lab sheet.

- **4.1 Tables.** Prints `n | xn | f(xn) | dn` for each method, with `dn = |x(n+1) - x(n)|`.
- **4.2 Plots.** Semi-log plots of `|f(xn)|` and of `dn` against `n`, for the three methods on one figure.
- **4.3 ACOC.** For each method, with `rn = dn / d(n-1)`:

      pn = ln(rn) / ln(r(n-1))

  `pn` estimates the order of convergence and is compared with the theoretical order.
- **4.4 Comparison.**
  - Accuracy: true error `|y - sqrt(3)|`, residual `|f(y)|`, and the error bound `|f(y)| / mm`, where `mm = min |f'|` on `[1, 2]` (here `mm = 2`). The bound does not need the exact root.
  - Cost: `p` (theoretical order), `m` (calls to `f` or `f'` per iteration), efficiency index `E = p^(1/m)`, and total evaluations.
  - Notes computed from the numbers: ranking by iterations, evaluations and efficiency, trade-offs, accuracy, and agreement between experimental and theoretical orders.

## Results

Output of `exec("main.sce", -1)` with the parameters above.

### Convergence and cost

| Method | Iterations | Theoretical order p | m | E = p^(1/m) | Total evaluations |
|---|---|---|---|---|---|
| NEWTON | 5 | 2 | 2 | 1.4142 | 10 |
| SECANTE | 7 | 1.618 | 1 | 1.6180 | 8 |
| OSTROWSKI | 3 | 4 | 3 | 1.5874 | 9 |

Evaluations: Newton `5 x 2`, Ostrowski `3 x 3`, Secant `7 + 1` (the extra one is the second starting value).

### Accuracy

| Method | Root found | `|y - r|` | `|f(y)|` | Bound `|f(y)|/2` |
|---|---|---|---|---|
| NEWTON | 1.732050807568877 | 2.2e-16 | 1.776e-15 | 8.882e-16 |
| SECANTE | 1.732050807568877 | 2.2e-16 | 1.776e-15 | 8.882e-16 |
| OSTROWSKI | 1.732050807568877 | 0 | 1.776e-15 | 8.882e-16 |

### Experimental order of convergence (last ACOC value)

| Method | Last pn | Theory |
|---|---|---|
| NEWTON | 2.0002 | 2 |
| SECANTE | 1.6508 | 1.618 |
| OSTROWSKI | 3.9223 | 4 |

### Observations

- **Order of convergence.** The experimental orders agree with the theory. Newton's `pn` settles at 2 (2.0160, 2.0029, 2.0002). Secant's `pn` oscillates around 1.618 because its error depends on the two previous errors. Ostrowski has only one valid `pn` after 3 iterations, so that check is weaker; the error ratio `e(n+1)/e(n)^4 ≈ 0.213` is close to the predicted constant 0.2114.
- **Accuracy is a tie.** All three methods reach the limit of double precision. The `0` for Ostrowski is not "more accurate": `sqrt(3)` is itself a rounded number, and Ostrowski's last iterate landed on exactly that double, while Newton and Secant landed on the next double up (a gap of 2.22e-16). Measured against the true `sqrt(3)`, the three errors are all about 1e-16.
- **Why `|f(y)|` stops at 1.776e-15.** Near `x = 1.73`, the terms `x^3` and `3x` are about 5.2 and nearly cancel. Doubles of that size lie on a grid of spacing 8.9e-16, so 1.776e-15 (two grid steps) is the smallest non-zero value `f` can show. This is a floating-point limit, not a defect of the methods.
- **Error bound.** The guaranteed bound `|f(y)|/mm = 8.9e-16` is above the true error for all three methods (check passed).
- **Ranking.**
  - By iterations: Ostrowski (3) < Newton (5) < Secant (7).
  - By efficiency index `E` and by total evaluations: Secant > Ostrowski > Newton.
  - A higher order saves iterations, but each iteration costs more calls. Ostrowski's extra call per step (m = 3 instead of 2) raises `E` from 1.4142 to 1.5874 compared with Newton.

The convergence plots are in `results/plot_residual.png` (`log10 |f(xn)|`) and `results/plot_step.png` (`log10 dn`).

## Remarks and limitations

- The comparison counts `m = 1` for `SECANTE`, because `f(x(n-1))` can be reused. Our `SECANTE` code recomputes it, so it really makes 2 calls per iteration (14 in total here instead of 8).
- `Display_record` and `Display_ACOC` print `-` where a value does not exist: the last point has no `dn`, the first rows have no `rn`, and the first two rows have no `pn`.
- Plots skip values that are exactly 0 or `NaN`, since their logarithm is undefined.
- All three methods are local. The results hold for one smooth function with a simple root and a good starting point; other functions or poor starting points may give different behaviour or fail to converge.
- The files `main.sce~` and `NEWTON.sci~` are editor backup copies and are not used by the project.