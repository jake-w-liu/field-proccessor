using RadiationPatterns
using CSV
using DataFrames
using FFMPEG
using PlotlyJS
using Infiltrator
# using Thread.@threads

Base.@kwdef mutable struct Settings
    step::Int = 12000
    stop::Int = 120000
    # rg::Vector{Float64} = []
    rg::Vector{Float64} = [0, 1600]
    # xrange = []
    # yrange = []
    xrange = [-50e-6, 150e-6]
    yrange = [-100e-6, 100e-6]
    sq::Bool = true
    dg::Int = 2
    fsize::Int = 1800
    folder_name::String = "./tmp/20241216_density_2um/constant/density_0.500/radius_0.5/"
    # folder_name::String = "./tmp/paper_animation/constant_360_0/"
end

function read_field(name, ds = 1, sq = true)
    df = CSV.read(name, DataFrame; header=false)
    ny = findall(x -> x == df.Column2[1], df.Column2)[2] - 1
    nx = Int(length(df.Column2)/ny)
    U = transpose(reshape(df.Column3, (ny, nx)))
    U .= abs.(U) 
    if sq
        U .= U.^2
    end
    x = collect(range(-nx/2*ds, nx/2*ds, nx))
    y = collect(range(-ny/2*ds, ny/2*ds, ny))
    Pat = Pattern(U, x, y)
    return Pat
end

function read_field_raw(name, sq = false)
    df = CSV.read(name, DataFrame; header=false)
    ny = findall(x -> x == df.Column2[1], df.Column2)[2] - 1
    nx = Int(length(df.Column2)/ny)
    U = transpose(reshape(df.Column3, (ny, nx)))
    U .= abs.(U) 
    if sq
        U .= U.^2
    end
    return U
end

function read_field_raw(name, nx, ny, sq = false)
    df = CSV.read(name, DataFrame; header=false)
    U = transpose(reshape(df.Column3, (ny, nx)))
    U .= abs.(U) 
    if sq
        U .= U.^2
    end
    return U
end

function plot_field(Pat, zrange = [])
    if length(zrange) == 0
        ptn_holo(Pat)
    else
        ptn_holo(Pat, zrange=zrange)
    end
end

function process_forward_single(set, stop, figure_name="")
    name = set.folder_name * "Ez_t" * string(stop) * ".field_dump"
    Pat = read_field(name, 1e-6/3, set.sq)
    plt = plot_field(Pat, set.rg)
    plt.plot.data[1].colorbar = attr(tickfont=attr(size=32), len=0.9)

    update_xaxes!(plt, showticklabels=false)
    update_yaxes!(plt, showticklabels=false)

    if !isempty(set.xrange)
        plt.plot.layout.xaxis[:range] = set.xrange
    end
    if !isempty(set.yrange)
        plt.plot.layout.yaxis[:range] = set.yrange
    end

    if figure_name == ""
        figure_name = set.folder_name * "forward_single_" *  string(stop) * ".png"
    end

    savefig(
            plt,
            figure_name;
            height = set.fsize,
            width = round(Int, set.fsize / (Pat.x[2] - Pat.x[1]) *(Pat.y[2] - Pat.y[1])),
        )
    return Pat, plt
end

function process_forward(set)
        
    figure_name = set.folder_name * "forward_" * lpad(0, set.dg, '0') * ".png"
    Pat, plt = process_forward_single(set, 1, figure_name)

    for nt = 1:round(Int, set.stop/set.step)
        name = set.folder_name * "Ez_t" * string(nt*set.step) * ".field_dump"
        figure_name = set.folder_name * "forward_" * lpad(nt, set.dg, '0') * ".png"
        
        Pat.U .= read_field_raw(name, length(Pat.x),  length(Pat.y), set.sq)
        react!(plt, plt.plot.data, plt.plot.layout)

        savefig(
            plt,
            figure_name;
            height = set.fsize,
            width = round(Int, set.fsize / (Pat.x[2] - Pat.x[1]) *(Pat.y[2] - Pat.y[1])),
        )

        println(nt)
    end

    framerate = 1
    png_name = set.folder_name * "forward_" * "%0$(set.dg)d.png"
    gif_name = set.folder_name * "Ez_forward.gif"

    FFMPEG.ffmpeg_exe(`-framerate $(framerate) -f image2 -i $(png_name) -y $(gif_name)`)
end


function process_playback_single(set, stop, figure_name="")
    name = set.folder_name * "Ez_t" * string(stop) * ".pi102_field_dump"
    Pat = read_field(name, 1e-6/3, set.sq)
    plt = plot_field(Pat, set.rg)
    plt.plot.data[1].colorbar = attr(tickfont=attr(size=32), len=0.9)

    update_xaxes!(plt, showticklabels=false)
    update_yaxes!(plt, showticklabels=false)
    if !isempty(set.xrange)
        plt.plot.layout.xaxis[:range] = set.xrange
    end
    if !isempty(set.yrange)
        plt.plot.layout.yaxis[:range] = set.yrange
    end
    react!(plt, plt.plot.data, plt.plot.layout)
    if figure_name == ""
        figure_name = set.folder_name * "playback_single_" *  string(stop) * ".png"
    end
    savefig(
            plt,
            figure_name;
            height = set.fsize,
            width = round(Int, set.fsize / (Pat.x[2] - Pat.x[1]) *(Pat.y[2] - Pat.y[1])),
        )
    return Pat, plt
end

function process_playback(set)
        
    figure_name = set.folder_name * "playback_" * lpad(0, set.dg, '0') * ".png"
    Pat, plt = process_playback_single(set, 1, figure_name)

    for nt = 1:round(Int, set.stop/set.step)
        name = set.folder_name * "Ez_t" * string(nt*set.step) * ".pi102_field_dump"
        figure_name = set.folder_name * "playback_" * lpad(nt, set.dg, '0') * ".png"
        
        Pat.U .= read_field_raw(name, length(Pat.x),  length(Pat.y), set.sq)
        react!(plt, plt.plot.data, plt.plot.layout)

        savefig(
            plt,
            figure_name;
            height = set.fsize,
            width = round(Int, set.fsize / (Pat.x[2] - Pat.x[1]) *(Pat.y[2] - Pat.y[1])),
        )

        println(nt)
    end

    framerate = 1
    png_name = set.folder_name * "playback_" * "%0$(set.dg)d.png"
    gif_name = set.folder_name * "Ez_playback.gif"

    FFMPEG.ffmpeg_exe(`-framerate $(framerate) -f image2 -i $(png_name) -y $(gif_name)`)
end


set = Settings()
# process_forward(set);
# process_playback(set);
# process_forward_single(set, 12000);
process_playback_single(set, 120000);
println()


