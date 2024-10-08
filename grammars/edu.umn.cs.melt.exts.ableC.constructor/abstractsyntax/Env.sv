grammar edu:umn:cs:melt:exts:ableC:constructor:abstractsyntax;

synthesized attribute constructors::Scopes<Constructor> occurs on Env;
synthesized attribute constructorContribs::Contribs<Constructor> occurs on Defs, Def;

aspect production emptyEnv
top::Env ::=
{
  production attribute globalConstructors::[(String, Constructor)] with ++;
  globalConstructors := [];

  top.constructors = addScope(globalConstructors, emptyScope());
}
aspect production addDefsEnv
top::Env ::= d::Defs  e::Env
{
  top.constructors = addGlobalScope(gd.constructorContribs, addScope(d.constructorContribs, e.constructors));
}
aspect production openScopeEnv
top::Env ::= e::Env
{
  top.constructors = openScope(e.constructors);
}
aspect production globalEnv
top::Env ::= e::Env
{
  top.constructors = globalScope(e.constructors);
}
aspect production nonGlobalEnv
top::Env ::= e::Env
{
  top.constructors = nonGlobalScope(e.constructors);
}
aspect production functionEnv
top::Env ::= e::Env
{
  top.constructors = functionScope(e.constructors);
}

aspect production nilDefs
top::Defs ::=
{
  top.constructorContribs = [];
}
aspect production consDefs
top::Defs ::= h::Def  t::Defs
{
  top.constructorContribs = h.constructorContribs ++ t.constructorContribs;
}

aspect default production
top::Def ::=
{
  top.constructorContribs = [];
}

production constructorDef
top::Def ::= s::String  c::Constructor
{
  top.constructorContribs = [(s, c)];
}

fun lookupConstructor [Constructor] ::= n::String e::Env =
  lookupScope(n, e.constructors);
