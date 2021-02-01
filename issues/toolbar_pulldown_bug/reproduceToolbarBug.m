f = uifigure;
g = uigridlayout(f,[2 1]);
g.RowHeight = {80, '1x'};

tb = wt.Toolbar(g);
dummy = uipanel(g,'BackgroundColor','red');

tb.Section = [
    addSection()
    addSection()
    addSection()
    addSection()
    ];


function s = addSection()

s = wt.toolbar.HorizontalSection();
for idx = 1:4
    s.addButton("", string(idx));
end

end