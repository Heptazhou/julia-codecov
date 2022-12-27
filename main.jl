const bool(s::AbstractString) = parse(Bool, s)

using Pkg

Pkg.activate("coverage_temp_env", shared = true)
Pkg.add(PackageSpec(name = "CoverageTools"))

using CoverageTools

dirs = get(ENV, "INPUT_DIRECTORY", "src")
file = get(ENV, "INPUT_LCOV_FILE", "lcov.info")
keep = get(ENV, "INPUT_LCOV_KEEP", "1") |> bool
skip = get(ENV, "INPUT_SKIP_MISS", "0") |> bool

dirs = filter!(!isempty, split(dirs, r":|\n"))
skip && filter!(ispath, dirs)
for dir in dirs
	isdir(dir) || error("`$dir` is not a directory")
end
isdir(file) && error("`$file` is a directory")

fcs = keep && isfile(file) ? LCOV.readfile(file) : vcat(process_folder.(dirs)...)
LCOV.writefile(file, fcs)

cvr, tot = get_summary(fcs)
pct = round(100cvr / tot, digits = 2)
@info "$cvr / $tot ($pct%)"

