default-timeout=4500

margin={{custom.spacing_3}}
padding={{custom.spacing_3}}
border-radius={{custom.rounding}}
border-size=0
progress-color={{colors.surface_container_high.default.hex}}
icon-path=/run/current-system/sw/share/icons/hicolor

[urgency=low]
background-color={{colors.surface_container.default.hex}}
text-color={{colors.on_surface.default.hex}}

[urgency=normal]
background-color={{colors.primary_container.default.hex}}
text-color={{colors.on_primary_container.default.hex}}

[urgency=critical]
background-color={{colors.error_container.default.hex}}
text-color={{colors.on_error_container.default.hex}}

[app-name=brightness]
layer=overlay
anchor=top-center
text-alignment=center

[app-name=volume]
layer=overlay
anchor=top-center
text-alignment=center
