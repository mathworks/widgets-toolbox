%% Create animal
a = wt.example.model.Animal("Debug",true);
a.Name = "Giraffe X";
a.BirthDate = datetime("today") - years(7.5);
a.Species = "giraffe";

%% Create enclosure, add animal to it
n = wt.example.model.Enclosure("Debug",true);
n.Name = "Giraffe Pen";
n.Animal = a;

%% Create exhibit, add enclosure to it
x = wt.example.model.Exhibit("Debug",true);
x.Name = "African Safari";
x.Enclosure = n;

%% Add another animal to the enclosure
a2 = wt.example.model.Animal("Debug",true);
a2.Name = "Giraffe Y";
a2.Species = "giraffe";
a2.BirthDate = datetime("today") - years(4);
a2.Sex = "male";
n.Animal(end+1) = a2;

%% Attach to session
s = wt.example.model.Session("Debug",true,"Exhibit",x);


%% Change a property
a.Sex = "female";

%% Investigate listener/event issue:
a.BirthDate = a.BirthDate - days(1);