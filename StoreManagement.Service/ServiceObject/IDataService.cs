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
        /*IQueryable<T_Chemical> GetAllChemicals();
        //DataTable ExecStoredProc();
        void Insert(T_Chemical chemical);
        void Update(T_Chemical chemical);
        T_Chemical Get(int key);*/

        DataTable GetDataFromConfiguration(int userId, GridViewConfig gridConfig);
        IList<Dictionary<string, object>> GetDataFromConfigurationJsonable(int userId, GridViewConfig gridConfig);
        int CountDataFromConfiguration(int userId, GridViewConfig gridConfig);
        Dictionary<string, object> SumDataFromConfiguration(int userId, GridViewConfig gridConfig);

        Dictionary<string, object> GetObject(int userId, string tableName, string columName, string columValue);
        void SaveObject(int userId, string tableName, string objectData);
        void DeleteObject(int userId, string tableName, string columName, string columValue);

    }
}
