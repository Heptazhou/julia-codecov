using Pkg

Pkg.activate("coveragetempenv", shared = true)
Pkg.add(PackageSpec(name = "CoverageTools"))

using CoverageTools

dirs = get(ENV, "INPUT_DIRECTORY", "src")
lcov = get(ENV, "INPUT_FILE_LCOV", "lcov.info")
ign = parse(Bool, get(ENV, "INPUT_FORCE", "false"))

dirs = filter!(!isempty, split(dirs, ":"))
for dir in dirs
	isdir(dir) || error("`$dir` is not a directory")
end
isdir(lcov) && error("`$lcov` is a directory")

fcs = !ign && isfile(lcov) ? LCOV.readfile(lcov) : vcat(process_folder.(dirs)...)
LCOV.writefile(lcov, fcs)

cvr, tot = get_summary(fcs)
pct = round(100cvr / tot, digits = 2)
@info "$cvr / $tot ($pct%)"

