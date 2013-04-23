(function(){ Meteor._def_template("model",Handlebars.json_ast_to_func(["<div id=\"modelContainer\" tabindex=\"1\" autofocus=\"autofocus\"></div>\n  ",["{",[[0,"handleModelPermission"]]],"\n  ",["{",[[0,"create"]]],"\n  ",[">","modelSidebar"]]));
Meteor._def_template("modelSidebar",Handlebars.json_ast_to_func(["<div class=\"slide-main\">\n    <div class=\"slideOutArrow\">Infos</div>\n    <div class=\"slide-container\">\n      <ul id=\"slideContainerListItems\">\n        <li>Modelname\n          <ul>\n            <li>\n              <div class=\"modelname\">",["{",[[0,"modelname"]]],"</div>\n            </li>\n          </ul>\n        </li>\n        <li>UpdatedAt\n          <ul>\n            <li>\n              <div class=\"updatedAt\">",["{",[[0,"updatedAt"]]],"</div>\n            </li>\n          </ul>\n        </li>\n        <li>Invited\n          <ul>\n            ",["#",[[0,"each"],[0,"invited"]],["          \n              <li>\n                <div class=\"invited\">",["{",[[0,"","name"]]],"</div><div class=\"invitedRole\">",["{",[[0,"","role"]]],"</div>\n              </li>\n            "]],"\n          </ul>\n        </li>      \n        <li>Tags\n          <ul>\n            ",["#",[[0,"each"],[0,"tags"]],["          \n              <li>\n                <div class=\"tags\">",["{",[[0]]],"</div>\n              </li>\n            "]],"\n          </ul>\n        </li>            \n        <li>Creator\n          <ul>\n            <li>\n              <div class=\"creator\">",["{",[[0,"creator"]]],"</div>\n            </li>\n          </ul>\n        </li>        \n        ",["#",[[0,"if"],[0,"predecessor"]],["\n          <li>Predecessor\n            <ul>\n              <li>\n                <div class=\"predecessor\">",["{",[[0,"predecessor"]]],"</div>\n              </li>\n            </ul>\n          </li>\n        "]],"\n        <li>IsPublic\n          <ul>\n            <li>\n              <div class=\"isPublic\">",["{",[[0,"isPublic"]]],"</div>\n            </li>\n          </ul>\n        </li>        \n      </ul>\n      ",["#",[[0,"if"],[0,"currentUser","services"]],["\n        ",["#",[[0,"if"],[0,"isFavourited"]],["\n          <input type=\"button\" id=\"favourite\" value=\"Favourite\">\n        "],["\n          <input type=\"button\" id=\"defavourite\" value=\"Defavourite\">\n        "]],"\n        <input type=\"button\" id=\"clone\" value=\"Clone\">\n      "]],"\n    </div>\n  </div>  \n\n  <datalist hidden id=\"profilesDatalist\">\n    ",["#",[[0,"each"],[0,"profilesList"]],["\n      <option value=\"",["{",[[0,"name"]]],"\">\n    "]],"\n  </datalist>"]));
Meteor._def_template("modelEdit",Handlebars.json_ast_to_func([["#",[[0,"if"],[0,"currentUser","services"]],["\n    ",["{",[[0,"test"]]],"\n  "]]]));

})();