﻿angular.module('webtools').service('uasModel', function () {
    this.selectedType = null;
    this.types = [];
    this.updateType = null;
    this.installType = null;

    this.list = [];
    this.installedList = [];
    this.updateList = [];
});
