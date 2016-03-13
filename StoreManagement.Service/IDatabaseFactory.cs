using StoreManagement.Data;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Reflection;

namespace StoreManagement.Service
{
    public interface IDatabaseFactory : IDisposable
    {
        #region Public Methods and Operators

        /// <summary>
        /// The get.
        /// </summary>
        /// <returns>
        /// The <see cref="T"/>.
        /// </returns>
        DbContext GetDbContext();
        StoreManagementEntities GetContext();
        SharpRepository.Repository.IRepository<T> GetRepository<T>() where T:class, new();        
        
        #endregion
    }

    public class DatabaseFactory : IDatabaseFactory
    {
        private DbContext dataContext;
        private readonly string connectionString;

        #region Constructors and Destructor

        /// <summary>
        /// Initializes a new instance of the <see cref="DatabaseFactory{T}"/> class.
        /// </summary>
        /// <param name="connectionString">
        /// The connection string.
        /// </param>
        public DatabaseFactory(string connectionString)
        {
            this.connectionString = connectionString;
        }

        #endregion

        public DbContext GetDbContext()
        {
            if (this.dataContext == null)
            {
                Type type = typeof(StoreManagement.Data.StoreManagementEntities);
                this.dataContext =
                    (StoreManagement.Data.StoreManagementEntities)
                    type.InvokeMember(
                        type.Name,
                        BindingFlags.CreateInstance,
                        null,
                        null,
                        null);
            }

            return this.dataContext;
        }

        public StoreManagementEntities GetContext()
        {
            return (StoreManagementEntities)GetDbContext();
        }

        public SharpRepository.Repository.IRepository<T> GetRepository<T>() where T: class, new()
        {
            return new SharpRepository.EfRepository.EfRepository<T>(this.GetDbContext());
        }

        #region IDisposable

        private bool isDisposed;

        ~DatabaseFactory()
        {
            this.Dispose(false);
        }

        public void Dispose()
        {
            this.Dispose(true);
            GC.SuppressFinalize(this);
        }

        private void Dispose(bool disposing)
        {
            if (!this.isDisposed && disposing && this.dataContext != null)
            {
                this.dataContext.Dispose();
            }

            this.isDisposed = true;
        }

        #endregion
    }
}
