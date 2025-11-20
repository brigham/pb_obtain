This is a scratchpad for future plans.

# Developer Experience
The main purpose of this package is to generate DTOs that simplify
building requests and parsing responses to/from PocketBase.

We need to look into removing the required meta argument.

We should consider whether a builder for the whole request would
be better than separate arguments that require multiple references
to the DTO type.

# build_runner
My current understanding is that it would better to use build_runner
instead of our custom script.

# Dependency Optimization
This package contains a lot of code generation code, but also
dependencies needed during runtime. At some point, we may want to
split it into two packages to allow for cleaner dependency trees.

# lib/src/sample Cleanup
The `lib/src/sample` directory contains generated DTOs used for testing. It is currently gitignored and not vended, but causes static analysis errors and coverage noise.

Plan:
1. Move `lib/src/sample` to `test/generated_sample`.
   - This ensures the code is not vended in the package.
2. Check in the generated files in `test/generated_sample`.
   - This resolves static analysis errors for fresh clones.
   - Changes to the generator will require updating these files (handled by `precommit.sh`).
3. Move `bin/filter_playground.dart` to `test/playground.dart`.
   - Since it depends on the sample DTOs (now in `test/`), it cannot reside in `bin/` or `example/` as those are published directories.
4. Update `test/test_schema/pb_dto_gen.yaml` and `test/sample_test_runner.dart` to target the new location.
5. Update `test/sample_test.dart` imports.
6. Remove `lib/src/sample` from `COVERAGE.csv` (coverage of generated test code is not required).
