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

// Total evaluations needed to reach e. We count how many points x_k had to be
// evaluated: NEWTON/OSTROWSKI evaluate x0..x(n-1) (m calls each);
// SECANTE evaluates x0..x(n) once each (the 2 starting values are included).
tot = [m_eval(1)*nN,  nS + 1,  m_eval(3)*nO];

// Course slide 47: if |f'(x)| >= mm on the interval, then |x - r| <= |f(x)| / mm.
// This gives a guaranteed error bound WITHOUT knowing the exact root.
xx = linspace(1, 2, 1001);
mm = min(abs(df(xx)));               // = f'(1) = 2 on [1,2]
errs  = abs(ys - r_exact);           // true errors
resid = zeros(1,3); bound = zeros(1,3);
for i = 1:3
    resid(i) = abs(f(ys(i)));
    bound(i) = resid(i) / mm;
end

mprintf("\n~~~~ Part 4.4 : comparison (tolerance %g, stopping test |x(n+1) - x(n)| < e) ~~~~\n", e);
mprintf("%-10s %5s %12s %12s %12s %7s %2s %8s %6s\n", ..
        "method", "iters", "|y - r|", "|f(y)|", "bound", "p", "m", "E", "evals");
for i = 1:3
    mprintf("%-10s %5d %12.3e %12.3e %12.3e %7.3f %2d %8.4f %6d\n", ..
            names(i), iters(i), errs(i), resid(i), bound(i), p_th(i), m_eval(i), E_idx(i), tot(i));
end
mprintf("\nbound = |f(y)| / mm with mm = min|df| on [1,2] = %g  (course, slide 47)\n", mm);
mprintf("evals = total evaluations of f or df. Newton: n x 2, Ostrowski: n x 3, Secant: n + 1 (start-up included).\n");

mprintf("\nRoot found:\n");
for i = 1:3
    mprintf("  %-10s y = %.15f\n", names(i), ys(i));
end

// last finite ACOC value per method (experimental order) and how many values exist
Ls = list(AN, AS, AO);
nvalid = zeros(1,3);
mprintf("\nLast available ACOC value p_n (experimental) vs theory:\n");
for i = 1:3
    A = Ls(i);
    k = find(~isnan(A(:,6)));
    nvalid(i) = size(k, "*");
    if isempty(k) then
        mprintf("  %-10s : no valid p_n (too few iterations)  | theory %.3f\n", names(i), p_th(i));
    else
        mprintf("  %-10s : p_n = %.4f (n = %d)  | theory %.3f\n", names(i), A(k($),6), A(k($),1), p_th(i));
    end
end

// ---------- 7. Notes (computed from the results above, not typed in) ----------
mprintf("\n~~~~ Notes ~~~~\n");

// accuracy
if max(errs) < 10 * %eps * r_exact then
    mprintf("- Accuracy: all three reach the double-precision limit (about %.1e), so accuracy is essentially tied.\n", %eps);
else
    [vv, kk] = min(errs);
    mprintf("- Accuracy: the smallest true error is %.3e (%s); the errors differ.\n", vv, names(kk));
end
if and(errs <= bound) then
    mprintf("- The slide-47 bound is >= the true error for all three methods (check passed).\n");
else
    mprintf("- WARNING: a bound is smaller than the true error; check mm and the interval.\n");
end

// efficiency ranking
[vE, kE] = gsort(E_idx, "g", "d");
[vT, kT] = gsort(tot,   "g", "i");
mprintf("- Ranking by efficiency index E (best first): %s > %s > %s\n", names(kE(1)), names(kE(2)), names(kE(3)));
mprintf("- Ranking by total evaluations (fewest first): %s < %s < %s\n", names(kT(1)), names(kT(2)), names(kT(3)));
[vI, kI] = gsort(iters, "g", "i");
mprintf("- Ranking by iterations (fewest first): %s < %s < %s\n", names(kI(1)), names(kI(2)), names(kI(3)));

// ACOC reliability
for i = 1:3
    if nvalid(i) < 2 then
        mprintf("- %s has only %d usable p_n value(s): it converges in few iterations, so the experimental order is weak evidence.\n", names(i), nvalid(i));
    end
end

// the Secant implementation really calls fonc twice per iteration
mprintf("- m counts every evaluation of f or df. Secant counts 1 because f(x(n-1)) can be reused;\n");
mprintf("  our SECANTE code recomputes it, so it really makes 2 calls per iteration.\n");
