module REPLHistoryDB

using Dates: DateTime, DateFormat
using REPL: find_hist_file

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
        elseif mode_str == "help"
            HelpMode()
        else
            CustomMode(mode_str)
        end
    else
        error("")
    end
    code = join(
        map(eachsplit(lines[3], '\n')) do line
            lstrip(line, '\t')
        end,
        '\n',
    )
    return Record(time, mode, rstrip(code, '\n'))
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

function readfile(filename=find_hist_file())
    blocks = String[]
    block = ""
    for line in eachline(filename)
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
