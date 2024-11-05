using RadiationPatterns
using CSV
using DataFrames
using FFMPEG
using PlotlyJS
using Infiltrator
# using Thread.@threads


folder_name = "./tmp/const_180_y/1600/"


function read_interface(name, ds = 1, sq = true)
    df = CSV.read(name, DataFrame; header=false)
    ny = length(df.Column2)
    nx = 1
    U = Matrix(transpose(reshape(df.Column3, (ny, nx))))
    U .= abs.(U) 
    if sq
        U .= U.^2
    end
    x = [0.0]
    y = collect(range(-ny/2*ds, ny/2*ds, ny))
    Pat = Pattern(U, x, y)
    return Pat
end

function process_interface(folder_name)
    name = folder_name * "interface_amp.dat" 
    intf = read_interface(name, 1/3, false)
    name = folder_name * "interface_amp_pi.dat" 
    intp = read_interface(name, 1/3, false)
    # @infiltrate
    fig = ptn_2d(
        [intp, intf],
        dims=2,
        name=["playback", "forward"],
        mode=["lines", "dash"],
        color=["red", "blue"],
        xlabel="position (µm)",
        ylabel="amplitude (a.u.)",
    )
    fig.plot.layout.height = 500
    fig.plot.layout.width = 600
    fig.plot.layout.legend = attr(xanchor = "right", yanchor = "top", x = 0.98, y = 0.95)
    fig.plot.data[1].line = attr(width=0.8) 
    fig.plot.data[2].line = attr(width=0.8, dash="dash") 
    react!(fig, fig.plot.data, fig.plot.layout)

    savefig(
        fig,
        folder_name * "interface_plot.png" ;
        height = 500,
        width = 600,
    )

    fig = ptn_2d(
        [intp, intf],
        dims=2,
        # name=["playback", "forward"],
        mode=["lines", "dash"],
        color=["red", "blue"],
        xlabel="(µm)",
        # ylabel="amplitude (a.u.)",
        xrange = [-20, 20],
    )
    fig.plot.layout.showlegend = false
    fig.plot.layout.legend = attr(xanchor = "right", yanchor = "top", x = 0.98, y = 0.95)
    fig.plot.data[1].line = attr(width=1) 
    fig.plot.data[2].line = attr(width=1, dash="dash") 
    react!(fig, fig.plot.data, fig.plot.layout)

    savefig(
        fig,
        folder_name * "interface_plot_zoom.png" ;
        height = 400,
        width = 440,
    )
    return nothing
end

# process_interface(folder_name)

# multi
intf = read_interface("tmp/exact/100/interface_amp.dat", 1/3, false)
inte = read_interface("tmp/exact/100/interface_amp_pi.dat", 1/3, false)
intca = read_interface("tmp/const/100/interface_amp_pi.dat", 1/3, false)
intca30 = read_interface("tmp/const_30/100/interface_amp_pi.dat", 1/3, false)

fig = ptn_2d(
        [intca, intca30, inte, intf],
        dims=2,
        name=["playback - CA full","playback - CA 30°","playback - exact", "forward"],
        mode=["lines"],
        color=["red", "darkred", "deeppink","blue"],
        xlabel="position (µm)",
        ylabel="amplitude (a.u.)",
        xrange = [-10, 10],
    )
    fig.plot.layout.legend = attr(xanchor = "right", yanchor = "top", x = 0.98, y = 0.98)
    # fig.plot.data[1].line = attr(width=1) 
    fig.plot.data[2].line = attr(dash="dashdot") 
    fig.plot.data[3].line = attr(dash="dot") 
    fig.plot.data[4].line = attr(dash="dash") 
    react!(fig, fig.plot.data, fig.plot.layout)

    savefig(
        fig,
        "interface_plot_zoom.png" ;
        height = 500,
        width = 550,
    )


