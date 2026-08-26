# EECE 306 lab documentation

Keep the instructor-provided API specification in the toolbox root and lab
handouts in `../Lab pdfs/` so they are easy to find while implementing code.
Put optional team design notes, derivations, and reusable references in this
directory.

The source-of-truth submission pattern for every lab is:

1. Package functions in `+em/+module/`.
2. A cumulative `tests/test_labNN.m` test script.
3. A publishable `LabNN_notebook.m` at the toolbox root.
4. A local `TeamNN_LabNN.zip` in `submissions/` for Canvas; ZIP files are not
   committed because Git already preserves the exact source snapshot.
