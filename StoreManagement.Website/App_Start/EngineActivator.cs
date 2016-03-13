using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using Autofac;
using Autofac.Integration.Mvc;
using SharpRepository.Repository;
using SharpRepository.Repository.Ioc;
using System.Reflection;
using System.Configuration;
using System.Web.Mvc;
using System.Security;
using Autofac.Integration.WebApi;
using System.Web.Http;
using StoreManagement.Service;

[assembly: PreApplicationStartMethod(typeof(StoreManagement.Website.EngineActivator), "Start")]
[assembly: SecurityRules(SecurityRuleSet.Level2)]

namespace StoreManagement.Website
{

    /// <summary>
    /// The engine activator.
    /// </summary>
    public static class EngineActivator
    {
        #region Properties

        /// <summary>
        /// Gets or sets the _container builder.
        /// </summary>
        private static ContainerBuilder _containerBuilder { get; set; }

        #endregion

        #region Public Methods and Operators

        /// <summary>
        /// The start.
        /// </summary>
        public static void Start()
        {
            if (_containerBuilder == null)
            {
                _containerBuilder = new ContainerBuilder();
            }

            RegisterInstance();

            //EngineContext.Initialize(false, _containerBuider);
            //DependencyResolver.SetResolver(
            //    new AutofacDependencyResolver(EngineContext.Current.ContainerManager.Container));
        }

        #endregion

        #region Methods

        /// <summary>
        /// The register instance.
        /// </summary>
        /// <param name="_containerBuider">
        /// The builder.
        /// </param>
        private static void RegisterInstance()
        {
            // tell Autofac to register all the controllers
            _containerBuilder.RegisterControllers(Assembly.GetExecutingAssembly());
            _containerBuilder.RegisterModule(new AutofacWebTypesModule());
            // todo registration module includes dependency injection bindings which is defined at the end of the post



            // tell Autofac to register all the controllers
            _containerBuilder.RegisterControllers(Assembly.GetExecutingAssembly());

            // tell Autofac to handled IRepository
            _containerBuilder.RegisterGeneric(typeof(ConfigurationBasedRepository<,>))
                   .As(typeof(IRepository<,>));

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ToString();

            _containerBuilder.RegisterType<DatabaseFactory>()
                .As<IDatabaseFactory>()
                .WithParameter(new NamedParameter("connectionString", connectionString))
                .InstancePerHttpRequest();
            
            _containerBuilder.RegisterAssemblyTypes(typeof(DataService).Assembly)
                .Where(t => t.Name.EndsWith("Service"))
                .AsImplementedInterfaces()
                .InstancePerHttpRequest();

            var container = _containerBuilder.Build();

            // setup the MVC5 dependency resolver
            DependencyResolver.SetResolver(new Autofac.Integration.Mvc.AutofacDependencyResolver(container));

            // setup the SharpRepository dependency resolver
            RepositoryDependencyResolver.SetDependencyResolver(new SharpRepository.Ioc.Autofac.AutofacDependencyResolver(container));
        }

        #endregion
    }
}