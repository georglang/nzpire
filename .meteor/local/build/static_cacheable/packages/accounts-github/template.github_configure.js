(function(){ Meteor._def_template("configureLoginServiceDialogForGithub",Handlebars.json_ast_to_func(["<p>\n    First, you'll need to get a Github Client ID. Follow these steps:\n  </p>\n  <ol>\n    <li>\n      Visit <a href=\"https://github.com/settings/applications/new\" target=\"blank\">https://github.com/settings/applications/new</a>\n    </li>\n    <li>\n      Set Main URL to to: <span class=\"url\">",["{",[[0,"siteUrl"]]],"</span>\n    </li>\n    <li>\n      Set Callback URL to: <span class=\"url\">",["{",[[0,"siteUrl"]]],"_oauth/github?close</span>\n    </li>\n  </ol>"]));

})();
