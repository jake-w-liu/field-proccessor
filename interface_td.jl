

folder_name = "./tmp/const/1600/"
name = folder_name * "Ez_t" * string(120000) * ".pi102_field_dump"
Patc = read_field(name, 1e-6/3, false)

folder_name = "./tmp/exact/1600/"
name = folder_name * "Ez_t" * string(120000) * ".pi102_field_dump"
Pate = read_field(name, 1e-6/3, false)

fig = ptn_2d(
        [Patc, Pate],
        dims=2,
        ind = 916,
        xrange = [-50e-6, 50e-6],
        name=["CA", "EA"],
        mode=["lines", "dash"],
        color=["red", "blue"],
        xlabel="position (µm)",
        ylabel="amplitude (a.u.)",
    )
    fig.plot.layout.height = 500
    fig.plot.layout.width = 600
    fig.plot.layout.legend = attr(xanchor = "right", yanchor = "top", x = 0.98, y = 0.95)
    fig.plot.data[1].line = attr(width=1) 
    fig.plot.data[2].line = attr(width=1, dash="dash") 
    react!(fig, fig.plot.data, fig.plot.layout)
    display(fig)

    # savefig(
    #     fig,
    #     folder_name * "interface_plot.png" ;
    #     height = 500,
    #     width = 600,
    # )



