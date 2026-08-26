# EECE 306 Electromagnetics Toolbox

**Team:** TODO - add team number and member names.

This MATLAB/GNU Octave package grows into an electrostatic and magnetostatic
field solver over EECE 306. The fixed function contract is in
`EECE306-API-Spec.pdf`; this repository owns the implementations, tests, and
published lab notebooks that demonstrate that contract.

## Run the tests

Start from this directory. Add the toolbox root - the folder containing
`+em` - to the path, never `+em` itself.

```sh
cd EECE306-Toolbox
octave --quiet --eval "runTests"
```

`runTests.m` and `+em/+test/assertClose.m` are provided by the course and must
not be modified. Every `tests/test_labNN.m` file is cumulative: new work must
keep all earlier lab tests passing.

## Lab deliverable pattern

For each lab, commit the implementation, its test file, and its notebook
together.

| Item | Location | Notes |
| --- | --- | --- |
| Toolbox functions | `+em/+module/` | Exact API names, Nx3 shape discipline, SI units |
| Regression tests | `tests/test_labNN.m` | Add checks; do not delete earlier checks |
| Lab notebook | `LabNN_notebook.m` | Run `publish('LabNN_notebook.m')` from this directory |
| Canvas ZIP | `submissions/TeamNN_LabNN.zip` | Local delivery bundle; ignored by Git |

Keep the initial `CONTENTS.m` placeholder until that package gains its first
real function, then replace it with documented `.m` functions. Every function
needs a useful MATLAB/Octave help block because grading includes `help` checks.

## Modules

| Module | Purpose | First lab |
| --- | --- | --- |
| `em.const` | Physical constants | 1 |
| `em.vec` | Vector algebra | 1 |
| `em.coord` | Coordinate and vector-component conversion | 2 |
| `em.src` | Charge and current source construction | 3 |
| `em.field` | Field evaluation and integrals | 3 |
| `em.viz` | Field visualization | 3 |
| `em.quad` | Numerical quadrature | 4 |
| `em.op` | Differential operators | 5 |
| `em.solve` | Boundary-value solvers | 7 |
| `em.derive` | Energy and derived quantities | 8 |
| `em.test` | Verification helpers | 1 onward |

## Lab 1

Implement `em.const.eps0`, `mu0`, `c0`, `eta0` and `em.vec.mag`, `unit`,
`angle`, `fromTo` against `Lab01-3.pdf`. Use `Lab01_notebook.m` to produce the
required report. The provided Lab 1 test currently fails until those eight
functions are in place; that is the expected initial state.
