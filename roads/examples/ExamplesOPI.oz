declare
[Roads] = {Module.link ['x-ozlib://wmeyer/roads/Roads.ozf']}
in
{Roads.registerFunctor examples 'x-ozlib://wmeyer/roads/examples/Examples.ozf'}
{Roads.run}

