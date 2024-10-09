using RadiationPatterns
using CSV
using DataFrames
using Infiltrator


folder_name = "./tmp/exact/1600"
step = 120000
name = folder_name * "/Ez_t" * string(step) * ".field_dump"

function read_field(name, sq = false)
    df = CSV.read(name, DataFrame; header=false)
    ny = findall(x -> x == df.Column2[1], df.Column2)[2] - 1
    nx = Int(length(df.Column2)/ny)
    U = transpose(reshape(df.Column3, (ny, nx)))
    U .= abs.(U) 
    if sq
        U .= U.^2
    end
    Pat = Pattern(U, collect(1:nx), collect(1:ny))
    return Pat
end

function plot_field(Pat, zrange = [])
    if length(zrange) == 0
        ptn_holo(Pat)
    else
        ptn_holo(Pat, zrange=zrange)
    end
end

function create_gif()
    
end

Pat = read_field(name)
# plot_field(Pat, [0, 10000])
plot_field(Pat)
