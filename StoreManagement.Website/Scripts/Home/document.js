var mdlDoc = angular.module('mdlDoc', ['ngSanitize']);


mdlDoc.controller('docController',
['$scope', '$filter', '$controller', '$sce',
    function ($scope, $filter, $controller, $sce) {
        $scope.common = {};
        $scope.menu = [
            {
                parent: 'bat-dau', title: '01 - Bắt đầu', deflt: 'dang-ky',
                pages: [
                  { page: 'dang-ky', title: 'Đăng ký', url: '' }
                ]
            },
            {
                parent: 'hang-hoa', title: '02 - Hàng hóa', deflt: 'quan-ly-hang-hoa',
                pages: [
                  { page: 'quan-ly-hang-hoa', title: 'Quản lý hàng hóa', url: '' },
                  { page: 'tao-hang-hoa', title: 'Thêm hàng hóa', url: '' },
                  { page: 'quan-ly-combo', title: 'Quản lý combo', url: '' },
                  { page: 'tao-combo', title: 'Thêm combo', url: '' }
                ]
            },
            {
                parent: 'don-hang', title: '03 - Bán hàng', deflt: 'pos',
                pages: [
                  { page: 'pos', title: 'POS bán hàng', url: '' },
                  { page: 'tao-don-hang', title: 'Tạo đơn hàng', url: '' },
                  { page: 'quan-ly-don-hang', title: 'Quản lý đơn hàng', url: '' }
                ]
            },
            {
                parent: 'khach-hang', title: '04 - Khách hàng', deflt :'quan-ly-khach-hang',
                pages: [
                  { page: 'quan-ly-khach-hang', title: 'Quản lý khách hàng', url: '' },
                  { page: 'quan-ly-nha-cung-cap', title: 'Nhà cung cấp', url: '' }
                ]
            },
            {
                parent: 'nhap-kho', title: '05 - Nhập kho', deflt: 'quan-ly-nhap-kho',
                pages: [
                  { page: 'quan-ly-nhap-kho', title: 'Quản lý nhập kho', url: '' },
                  { page: 'tao-phieu-nhap-kho', title: 'Tạo phiếu nhập kho', url: '' }
                ]
            },
            {
                parent: 'ton-kho', title: '06 - Tồn kho', deflt: 'quan-ly-ton-kho',
                pages: [
                  { page: 'quan-ly-ton-kho', title: 'Quản lý tồn kho', url: '' },
                  { page: 'nhap-xuat-kho', title: 'Nhập xuất kho', url: '' },
                  { page: 'xem-kiem-ke', title: 'Xem phiếu kiểm kê', url: '' },
                  { page: 'tao-kiem-ke', title: 'Tạo phiếu kiểm kê', url: '' },
                  { page: 'quan-ly-chuyen-kho', title: 'Xem phiếu chuyển kho', url: '' },
                  { page: 'tao-chuyen-kho', title: 'Tạo phiếu kiểm kê', url: '' }
                ]
            },
            {
                parent: 'thu-chi', title: '07 - Thu chi', deflt: 'chi-phi',
                pages: [
                  { page: 'chi-phi', title: 'Chi phí', url: '' },
                  { page: 'tien-ban-hang', title: 'Tiền bán hàng', url: '' },
                  { page: 'nhan-tien', title: 'Nhận tiền', url: '' }
                ]
            },
            {
                parent: 'doanh-so', title: '08 - Doanh số', deflt: 'doanh-so',
                pages: [
                  { page: 'doanh-so', title: 'Báo cáo doanh số', url: '' }
                ]
            },
            {
                parent: 'loi-nhuan', title: '09 - Lợi nhuận', deflt: 'loi-nhuan',
                pages: [
                  { page: 'loi-nhuan', title: 'Báo cáo lợi nhuận', url: '' }
                ]
            }
        ];
        //=====================
        $scope.GetPageInfo = function (page) {
            var page_info = { page: 'dang-ky', parentpage: 'bat-dau', parentpage_title: 'Bắt đầu', page_title: 'Đăng ký' };
            $.each($scope.menu, function (i, obj) {
                $.each(obj.pages, function (i, p) {
                    if (p.page == page) {
                        page_info.page = page;
                        page_info.parentpage = obj.deflt;
                        page_info.parentpage_title = obj.title;
                        page_info.page_title = p.title;
                    }
                });
            });
            return page_info;
        }
}]);

$(document).ready(function () {
    $('.menu-list-post').each(function (i, obj) {
        $(obj).hide();
    });
    $('.menu-widget > li > a').each(function (i, obj) {
        
        if ($(obj).parent().find('a.active').length != 0) {
            $(obj).addClass("active");

            var menu_listpost = $(obj).parent().find('.menu-list-post');
            $(menu_listpost).show();
        }
    });
});