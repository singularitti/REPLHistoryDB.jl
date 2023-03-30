module REPLHistoryDB

# Write your package code here.
abstract type REPLMode end
struct JuliaMode <: REPLMode end
struct PkgMode <: REPLMode end
struct ShellMode <: REPLMode end
struct CustomMode <: REPLMode
    mode::String
end

end
