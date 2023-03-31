module REPLHistoryDB

using Dates: DateTime, DateFormat, format
using REPL: find_hist_file

abstract type REPLMode end
struct JuliaMode <: REPLMode end
struct PkgMode <: REPLMode end
struct ShellMode <: REPLMode end
struct HelpMode <: REPLMode end
struct CustomMode <: REPLMode
    type::String
end

struct Record
    timestamp::DateTime
    mode::REPLMode
    input::String
end

# See https://github.com/JuliaLang/julia/blob/v1.9.0-rc1/base/uuid.jl#L48-L85
function Base.tryparse(::Type{Record}, str::AbstractString)
    lines = split(str, '\n'; limit=3, keepempty=false)
    line = lines[1]
    if startswith(line, "# time:")
        time_str = line[9:end]
        time_str = join(split(time_str, " "; keepempty=false)[1:2], " ")
        time = DateTime(time_str, DateFormat("yyyy-mm-dd HH:MM:SS"))
    else
        return nothing
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
        return nothing
    end
    input = join(
        map(eachsplit(lines[3], '\n')) do line
            lstrip(line, '\t')
        end,
        '\n',
    )
    return Record(time, mode, rstrip(input, '\n'))
end
function Base.parse(::Type{Record}, str::AbstractString)
    record = tryparse(Record, str)
    return record === nothing ? error("cannot parse record!") : record
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
        else  # `mode` or `input`
            block *= line * '\n'
        end
    end
    return filter(!isempty, blocks)
end

Base.show(io::IO, ::JuliaMode) = print(io, "julia")
Base.show(io::IO, ::PkgMode) = print(io, "pkg")
Base.show(io::IO, ::ShellMode) = print(io, "shell")
Base.show(io::IO, ::HelpMode) = print(io, "help")
Base.show(io::IO, mode::CustomMode) = print(io, mode.type)
Base.show(io::IO, record::Record) = print(io, record.input)
function Base.show(io::IO, ::MIME"text/plain", record::Record)
    println(io, summary(record))
    println(io, "time: ", format(record.timestamp, "yyyy-mm-dd HH:MM:SS"))
    println(io, "mode: ", record.mode)
    print(io, "input: ", record.input)
    return nothing
end

end
