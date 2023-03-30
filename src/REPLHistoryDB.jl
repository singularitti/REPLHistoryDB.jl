module REPLHistoryDB

using Dates: DateTime, DateFormat

abstract type REPLMode end
struct JuliaMode <: REPLMode end
struct PkgMode <: REPLMode end
struct ShellMode <: REPLMode end
struct CustomMode <: REPLMode
    mode::String
end

struct Record
    time::DateTime
    mode::REPLMode
    code::String
end

function parse(::Type{Record}, str::AbstractString)
    lines = split(str; limit=3, keepempty=false)
    @assert length(lines) == 3
    line = lines[1]
    if startswith(line, "# time:")
        time_str = line[9:end]
        time_str = join(split(time_str, " "; keepempty=false)[1:2], " ")
        time = DateTime(time_str, DateFormat("yyyy-mm-dd HH:MM:SS"))
    else
        error("")
    end
    line = lines[2]
    if startswith(line, "# mode:")
        mode = line[9:end]
        if mode == "julia"
            JuliaMode()
        elseif mode == "pkg"
            PkgMode()
        elseif mode == "shell"
            ShellMode()
        else
            CustomMode(mode)
        end
    else
        error("")
    end
    line = lines[3]
    code = join((subline[9:end] for subline in eachsplit(line)), '\n')
    return Record(time, mode, code)
end

end
