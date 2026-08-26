# EECE 305 / EECE 306 - Electromagnetics

Private course repository for EECE 305 (lecture) and EECE 306 (laboratory).
The laboratory work grows one tested MATLAB/GNU Octave toolbox throughout the
semester; do not treat each lab as a separate codebase.

## Repository layout

```
.
├── Lecture_Notes/                 EECE 305 lecture material
└── EECE306-Toolbox/               EECE 306 cumulative field-solver toolbox
    ├── +em/                       MATLAB/Octave package implementation
    ├── tests/                     Cumulative tests: test_lab01.m ... test_lab12.m
    ├── Lab01_notebook.m           Lab 1 publishable notebook template
    ├── docs/Lab01-3.pdf           Lab 1 requirements and submission format
    ├── EECE306-API-Spec.pdf       Fixed API contract for the semester
    ├── runTests.m                 Provided test runner - do not modify
    └── submissions/               Local ZIP bundles for Canvas (not committed)
```

## EECE 306 workflow

1. Work only inside `EECE306-Toolbox`; its root is the MATLAB/Octave path
   entry, never `+em` itself.
2. Add the functions due for the current lab to the specified `+em/+module/`
   package folder. Keep the exact names, signatures, shapes, and SI units in
   `EECE306-API-Spec.pdf`.
3. Add checks to `tests/test_labNN.m`. Old tests are permanent regression
   tests and must continue to pass.
4. From the toolbox root, run `octave --quiet --eval "runTests"` before each
   commit and before making a Canvas ZIP.
5. Complete `LabNN_notebook.m`, run `publish('LabNN_notebook.m')`, and export
   the generated HTML to the required PDF. Keep the source notebook in Git;
   generated HTML and ZIP packages are ignored.

## Lab 1 starting point

Lab 1 builds `em.const` and `em.vec`. The supplied tests intentionally fail
until the eight required functions are implemented. Use `Lab01_notebook.m` for
the required three-to-five-page published report, and leave `runTests.m` plus
`em.test.assertClose` unchanged.

## Git conventions

- Keep this repository **private** while it contains course work.
- Use one focused branch per lab, such as `lab/01-toolbox-basics`.
- Commit implementation, tests, and notebook updates together. A useful commit
  message is `lab01: add vector algebra functions and checks`.
- Never commit Canvas ZIPs, published HTML, Octave workspace files, or editor
  backups. PDFs that are source handouts or final reports may be committed.
