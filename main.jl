# Copyright (C) 2022-2023 Heptazhou <zhou@0h7z.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

const bool(s::AbstractString) = parse(Bool, s)

using Pkg

Pkg.activate("coverage_temp_env", shared = true)
Pkg.add(PackageSpec(name = "CoverageTools"))

using CoverageTools

dirs = get(ENV, "INPUT_DIRECTORY", "src")
file = get(ENV, "INPUT_LCOV_FILE", "lcov.info")
keep = get(ENV, "INPUT_LCOV_KEEP", "1") |> bool
skip = get(ENV, "INPUT_SKIP_MISS", "0") |> bool

dirs =
	filter!(!isempty, split(dirs, r":|\n"))
skip &&
	filter!(ispath, dirs)
@sync filter(!isdir, dirs) .|> dir -> (
	@error("`$dir` is not a directory"); @async error())
isdir(file) &&
	error("`$file` is a directory")

fcs = keep && isfile(file) ? LCOV.readfile(file) : mapreduce(process_folder, vcat, dirs)
LCOV.writefile(file, fcs)

cvr, tot = get_summary(fcs)
pct = round(100cvr // tot, digits = 2)
@info "$cvr / $tot ($pct%)"

