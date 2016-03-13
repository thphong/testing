mdlCommon.factory('translationFactory', ['$rootScope', function ($rootScope) {
    var sharedService = {};

    sharedService.translation = {};

    sharedService.prepForBroadcast = function (language) {
        //Default is english
        if (!language) {
            var lang = localStorage.getItem('autosave');

            if (!lang) {
                language = 'en';
            }
            else {
                language = lang;
            }
        }

        FValidation.ClearAllError();


        this.translation = JSON.parse(AjaxSync(GetLanguageService, '{ lang:"' + language + '"}'));
        this.broadcastItem();
    };

    sharedService.broadcastItem = function () {
        $rootScope.$broadcast('handleBroadcastTranslation');
    };

    function init() {
        var lang = localStorage.getItem('autosave');

        if (!lang) {
            lang = 'en';
        }
        $rootScope.Lang = lang;
        switch (lang) {
            case 'en': {
                $rootScope.LanguageName = 'English';
            } break;
            case 'vn': {
                $rootScope.LanguageName = 'Tiếng Việt';
            } break;
            default: break;

        }
    }

    init();

    return sharedService;
}]);

mdlCommon.controller('ctrlTranslating', ['$scope', 'translationFactory',
function ($scope, translationFactory) {

    //Run translation if selected language changes
    $scope.Translate = function (lang, languageName) {
        $scope.LanguageName = languageName;
        $scope.Lang = lang;
        setLangLocalStorage(lang);


        translationFactory.prepForBroadcast(lang);
    };

    //Init
    function supportsLocalStorage() {
        return typeof (Storage) !== 'undefined';
    }

    function setLangLocalStorage(lang) {
        if (!supportsLocalStorage()) {
            lang = 'en';
        } else {
            setInterval(function () {
                localStorage.setItem('autosave', lang);
            }, 1000);
        }
    }

}]);