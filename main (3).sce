// =====================================================================
// main.sce : Lab Work 1 - Root finding (Newton, Secant, Ostrowski)
// Run from Scilab with:   exec("main.sce", -1)
// =====================================================================
clear; clc;

// ---------- 0. Load every function file (same folder as this script) ----------
root = get_absolute_file_path("main.sce");
files = ["NEWTON.sci", "SECANTE.sci", "OSTROWSKI.sci", ..           // the 3 required methods
         "NEWTON_rec.sci", "SECANTE_rec.sci", "OSTROWSKI_rec.sci", ..  // same methods, but keep the history
         "Display_fun.sci", ..                                       // table printing (record + ACOC)
         "Approxim_Comp_Order_Conv.sci", ..                          // ACOC computation
         "plot_semilog.sci"];                                        // semi-log plots
for i = 1:size(files, "*")
    exec(root + files(i), -1);
end

// ---------- 1. Test problem (the lab sheet gives none: course example) ----------
function y = f(x), y = x.^3 + x.^2 - 3*x - 3, endfunction
function y = df(x), y = 3*x.^2 + 2*x - 3, endfunction

r_exact = sqrt(3);      // known root, only used to measure the true error
x0 = 2;                 // start for NEWTON and OSTROWSKI
r0 = 1; r1 = 2;         // two starts for SECANTE
e  = 1e-10;             // tolerance

mprintf("Test function: f(x) = x^3 + x^2 - 3x - 3, root = sqrt(3) = %.15f\n", r_exact);
mprintf("x0 = %g  |  r0 = %g, r1 = %g  |  tolerance e = %g\n", x0, r0, r1, e);

// ---------- 2. Run the three required functions ----------
[yN, nN] = NEWTON(f, df, x0, e);
[yO, nO] = OSTROWSKI(f, df, x0, e);

// SECANTE takes n as an INPUT, so find the smallest n with |x_n - x_(n-1)| < e
nS = 1;
while abs(SECANTE(r0, r1, f, nS) - SECANTE(r0, r1, f, nS-1)) >= e & nS < 100
    nS = nS + 1;
end
yS = SECANTE(r0, r1, f, nS);

// ---------- 3. Part 4.1 : tables  n | xn | f(xn) | dn ----------
TN = NEWTON_rec(f, df, x0, nN);
TS = SECANTE_rec(r0, r1, f, nS);
TO = OSTROWSKI_rec(f, df, x0, nO);

Display_record(TN, "NEWTON");
Display_record(TS, "SECANTE");
Display_record(TO, "OSTROWSKI");

// ---------- 4. Part 4.3 : ACOC tables ----------
AN = Approxim_Comp_Order_Conv(TN);
AS = Approxim_Comp_Order_Conv(TS);
AO = Approxim_Comp_Order_Conv(TO);

Display_ACOC(AN, "NEWTON");
Display_ACOC(AS, "SECANTE");
Display_ACOC(AO, "OSTROWSKI");

// ---------- 5. Part 4.2 : semi-log convergence plots ----------
// Plot_convergence(...) comes from plot_semilog.sci. col = 3 -> f(xn), col = 4 -> dn
// xs2png cannot create a missing folder, so create results/ first if needed
if ~isdir(root + "results") then
    mkdir(root + "results");
end

try
    Plot_convergence(TN, TS, TO, 3);
    xs2png(gcf(), root + "results/plot_residual.png");
    Plot_convergence(TN, TS, TO, 4);
    xs2png(gcf(), root + "results/plot_step.png");
    mprintf("\nPlots saved in the results/ folder.\n");
catch
    mprintf("\n(Plots skipped: %s)\n", lasterror());
end

// ---------- 6. Part 4.4 : performance comparison ----------
names  = ["NEWTON", "SECANTE", "OSTROWSKI"];
iters  = [nN, nS, nO];
ys     = [yN, yS, yO];
p_th   = [2, (1+sqrt(5))/2, 4];      // theoretical orders
m_eval = [2, 1, 3];                  // evaluations per iteration: f and f' count 1 each
                                     // Newton: f(xn), f'(xn)
                                     // Secant: f(xn) only (f(xn-1) is reusable)
                                     // Ostrowski: f(xn), f'(xn), f(yn) (f(xn), f'(xn) are reused)
E_idx  = p_th .^ (1 ./ m_eval);      // efficiency index E = p^(1/m)

// Total evaluations needed to reach e (m calls per iteration).
// NEWTON/OSTROWSKI: m * n.  SECANTE: n + 1 (f(x0) and f(x1) at the start, then 1 new call per iteration)
tot = [m_eval(1)*nN,  nS + 1,  m_eval(3)*nO];

// Error bound WITHOUT knowing the root: if |f'(x)| >= mm on [1,2], then |y - r| <= |f(y)| / mm
xx = linspace(1, 2, 1001);
mm = min(abs(df(xx)));               // = f'(1) = 2 on [1,2]
errs  = abs(ys - r_exact);           // true errors
resid = zeros(1,3); bound = zeros(1,3);
for i = 1:3
    resid(i) = abs(f(ys(i)));
    bound(i) = resid(i) / mm;
end

// (a) accuracy
mprintf("\n~~~~ Part 4.4 (a) : accuracy, stopping test |x(n+1) - x(n)| < %g ~~~~\n", e);
mprintf("%-10s %5s %20s %12s %12s %12s\n", "method", "iters", "root y", "|y - r|", "|f(y)|", "bound");
for i = 1:3
    mprintf("%-10s %5d %20.15f %12.3e %12.3e %12.3e\n", ..
            names(i), iters(i), ys(i), errs(i), resid(i), bound(i));
end
mprintf("r = sqrt(3).  bound = |f(y)| / mm, with mm = min|df| on [1,2] = %g\n", mm);

// (b) cost and efficiency
mprintf("\n~~~~ Part 4.4 (b) : cost and efficiency ~~~~\n");
mprintf("%-10s %6s %3s %8s %7s\n", "method", "p", "m", "E", "evals");
for i = 1:3
    mprintf("%-10s %6.3f %3d %8.4f %7d\n", names(i), p_th(i), m_eval(i), E_idx(i), tot(i));
end
mprintf("\nHow to read it:\n");
mprintf("  p      order of convergence (theory): 2, 1.618 (golden ratio), 4\n");
mprintf("  m      calls to f or df needed for ONE iteration (Newton 2, Secante 1, Ostrowski 3)\n");
mprintf("  E      = p^(1/m): order gained per call, the fair way to compare methods of different cost\n");
mprintf("  evals  total calls until the stopping test passes: Newton n x 2, Ostrowski n x 3,\n");
mprintf("         Secante n + 1 (f(x0) and f(x1) at the start, then one new call per iteration)\n");

// last finite ACOC value per method (experimental order) and how many values exist
Ls = list(AN, AS, AO);
nvalid = zeros(1,3);
plast  = %nan * ones(1,3);
mprintf("\n~~~~ Part 4.3 : last p_n against the theoretical order ~~~~\n");
for i = 1:3
    A = Ls(i);
    k = find(~isnan(A(:,6)));
    nvalid(i) = size(k, "*");
    if isempty(k) then
        mprintf("  %-10s : no valid p_n (too few iterations)  | theory %.3f\n", names(i), p_th(i));
    else
        plast(i) = A(k($),6);
        mprintf("  %-10s : p_n = %.4f (n = %d, %d value(s))  | theory %.3f\n", ..
                names(i), plast(i), A(k($),1), nvalid(i), p_th(i));
    end
end

// ---------- 7. Notes (computed from the numbers above, not typed in) ----------
mprintf("\n~~~~ Notes ~~~~\n");

[vI, kI] = gsort(iters, "g", "i");
[vT, kT] = gsort(tot,   "g", "i");
[vE, kE] = gsort(E_idx, "g", "d");
mprintf("- Iterations, fewest first  : %s (%d), %s (%d), %s (%d)\n", ..
        names(kI(1)), vI(1), names(kI(2)), vI(2), names(kI(3)), vI(3));
mprintf("- Evaluations, fewest first : %s (%d), %s (%d), %s (%d)\n", ..
        names(kT(1)), vT(1), names(kT(2)), vT(2), names(kT(3)), vT(3));
mprintf("- Efficiency E, best first  : %s (%.4f), %s (%.4f), %s (%.4f)\n", ..
        names(kE(1)), vE(1), names(kE(2)), vE(2), names(kE(3)), vE(3));

// trade-off between order and cost per step
if kI(1) <> kE(1) then
    mprintf("- Trade-off: %s needs the fewest iterations, but %s has the best efficiency index.\n", names(kI(1)), names(kE(1)));
    mprintf("  A higher order saves iterations, but each iteration costs more calls, so fewer iterations does not mean less work.\n");
else
    mprintf("- %s is best both in iterations and in efficiency index on this problem.\n", names(kI(1)));
end
if E_idx(3) > E_idx(1) then
    mprintf("- Ostrowski against Newton: one more call per step (m = 3 instead of 2) buys order 4 instead of 2, so E rises from %.4f to %.4f.\n", E_idx(1), E_idx(3));
else
    mprintf("- Ostrowski against Newton: the extra call per step does not pay off here (E = %.4f against %.4f).\n", E_idx(3), E_idx(1));
end

// accuracy
if max(errs) < 10 * %eps * r_exact then
    mprintf("- Accuracy: all three reach the limit of double precision (about %.1e), so accuracy is a tie.\n", %eps);
else
    [vv, kk] = min(errs);
    mprintf("- Accuracy: the smallest true error is %.3e (%s); the errors differ.\n", vv, names(kk));
end
if or(errs == 0) then
    mprintf("  An error of exactly 0 does not mean perfect: sqrt(3) is itself a rounded number, and that iterate landed on the same double.\n");
end
if and(errs <= bound) then
    mprintf("- The error bound |f(y)|/mm is above the true error for all three methods (check passed).\n");
else
    mprintf("- WARNING: a bound is smaller than the true error; check mm and the interval.\n");
end

// experimental order of convergence
mprintf("- Experimental order (last p_n against theory):\n");
for i = 1:3
    if nvalid(i) > 0 then
        gap = abs(plast(i) - p_th(i)) / p_th(i);
        if gap < 0.05 then
            verdict = "agrees with the theory";
        else
            verdict = "does NOT agree with the theory";
        end
        mprintf("    %-10s %.4f against %.3f : %s (%.1f %% apart)\n", names(i), plast(i), p_th(i), verdict, 100*gap);
        if nvalid(i) < 2 then
            mprintf("      (only %d value of p_n, so this is weak evidence on its own)\n", nvalid(i));
        end
    end
end

// the Secant implementation really calls fonc twice per iteration
mprintf("- m counts every call to f or df. Secante counts 1 because f(x(n-1)) can be reused;\n");
mprintf("  our SECANTE code recomputes it, so it really makes 2 calls per iteration (%d in total instead of %d).\n", 2*nS, nS + 1);
mprintf("- All three methods are local: these results hold for one smooth function with a simple root and a good starting point.\n");
