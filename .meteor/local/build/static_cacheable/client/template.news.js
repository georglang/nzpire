(function(){ Meteor._def_template("news",Handlebars.json_ast_to_func(["<div> NEWS TEMPLATE </div>\n\t",["#",[[0,"if"],[0,"currentUser","services"]],["\n\t\t",["#",[[0,"each"],[0,"getNews"]],["\n\t\t<div> ",["{",[[0,"name"]]],"_",["{",[[0,"updatedAt"]]]," </div>\n\t\t"]],"\n\t"]]]));

})();
