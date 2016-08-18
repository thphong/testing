using StoreManagement.Data;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoreManagement.Service
{
    public interface IDataService
    {
        Dictionary<string, object> Login(string LoginId, string Password);
        void Logout(int userId);

        DataTable GetDataFromConfiguration(int userId, GridViewConfig gridConfig);
        IList<Dictionary<string, object>> GetDataFromConfigurationJsonable(int userId, GridViewConfig gridConfig);
        int CountDataFromConfiguration(int userId, GridViewConfig gridConfig);
        Dictionary<string, object> SumDataFromConfiguration(int userId, GridViewConfig gridConfig);

        Dictionary<string, object> GetObject(int userId, string tableName, string columName, string columValue);
        int SaveObject(int userId, string tableName, string objectData);
        int SaveComplexObject(int userId, string tableName, string objectData, string subTableName, string subObjectData, string associatedColumn = "");
        void SaveListObject(int userId, string tableName, string objectData);
        void DeleteObject(int userId, string tableName, int keyValue, bool isHardDelete);
        bool CheckCanCreate(int userId, string tableName);
        bool CheckField(int userId, string field);

        Dictionary<string, object> GetRules(int userId, GridViewConfig gridConfig);
        IList<Dictionary<string, object>> ExecuteSQL(int userId, string sql);
    }
}
