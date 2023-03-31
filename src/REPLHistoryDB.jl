module REPLHistoryDB

using Dates: DateTime, DateFormat

abstract type REPLMode end
struct JuliaMode <: REPLMode end
struct PkgMode <: REPLMode end
struct ShellMode <: REPLMode end
struct HelpMode <: REPLMode end
struct CustomMode <: REPLMode
    mode::String
end

struct Record
    time::DateTime
    mode::REPLMode
    code::String
end

function Base.parse(::Type{Record}, str::AbstractString)
    lines = split(str, '\n'; limit=3, keepempty=false)
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
        mode_str = line[9:end]
        mode = if mode_str == "julia"
            JuliaMode()
        elseif mode_str == "pkg"
            PkgMode()
        elseif mode_str == "shell"
            ShellMode()
        else
            CustomMode(mode_str)
        end
    else
        error("")
    end
    line = lines[3]
    code = join((subline[9:end] for subline in eachsplit(line)), '\n')
    return Record(time, mode, code)
end

function readblocks(str::AbstractString)
    blocks = String[]
    block = ""
    for line in eachsplit(str, '\n')
        if startswith(line, "# time:")
            push!(blocks, block)  # Record `block`
            block = line * '\n'  # Clear and renew `block`
        else  # `mode` or `code`
            block *= line * '\n'
        end
    end
    return filter(!isempty, blocks)
end

end
