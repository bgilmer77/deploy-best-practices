# Dynamic Configuration and Resource Management: Overview

## Introduction

Metal as a Service ([MaaS]) and Infrastructure as Code ([IaC]) methodologies have emerged as best practices for deploying, configuring, and managing IT data center resources. Combined, they bring reliability, efficiency, and scale to the process of deploying and configuring servers, networks, authentication and security infrastructure, and application software services. Applying these IT industry best practices to media facilities brings the same benefits but demands adaptation to the unique requirements of media facilities.

MaaS and IaC methodologoies are built on top of long standing and very well understood standards. MaaS automation is built on a foundation of remote system management and network boot standards (i.e. [IPMI] and [PXE]). IaC is built on a foundation of secure shell interfaces for system access and well known scripting languages for configuration automation (e.g. [SSH] and [Python]). Binding these elements together to create a coherent deployment and configuration system is the job of a supervisory layer of software that is generically referred to as the "admin system" or "admin services". The admin system provides the human management interface from which resources are automatically allocated, deployed and configured. This admin system is new a component and is not built on long standing and very well understood standards.

The admin system is a resource management system. Resources are the individual servers, networking switches, network ports, video switches, and video production components, etc. The admin system is the manager and orchestrator of resource deployment and configuration. It is the central component in a dynamic configuration and resource management system. Everything beneath it is a layer of adaptation that brings individual resources into the managed domain of the admin system. What is administered, fundamentally, is the life-cycle of individual resources: initial discovery, unique identification, allocation, configuration, entry into production, release from production, and eventual decommissioning of the resource. Understanding this life-cycle in the context of MaaS and IaC methodologies provides a clearer understanding of where, and how, the unique requirements of media facilities must be adapted and where best practices still have to be developed.
    
## Resource Management Lifecycle

Resource management is represented using a simple life-cycle state model. A "resource" generically represents equipment that is managed by a process of identification, allocation, configuration, and commitment of the resource. Managing the deployment and configuration of a resource is the process of reliably moving the resource through this set of states.

![state model](images/resource-state-model.png)
<br>*Resource management lifecycle conceptual state model.*


| State | Description |
|---|---|
|registered | Resource existence and identity is recorded. |
|available | Resource is available for allocation to production. |
|allocated| Resource is allocated to production. |
|staged| Resource staging phase of configuration is complete. |
|committed| Resource final configuration is complete and it is committed to production. |
|accepted| Resources was accepted and is active in production. |
|released| Resource is no longer active in production. |
|retired | Resource is ready to be removed from the facility. |

Note that configuration happens in both the "staged" and the "committed" stage. Therefore resources may be considered to have two-phase configuration. This matches the deployment and configuration strategies used in some data centers where pools of servers with operating systems installed are "staged" ahead of time. Later, on demand, they recieve final configuration to meet a particular role before being "committed" to production. Other use cases that require two-phase configuration can be envisioned. If a simple resource only requires a single phase of configuration then staging is optional.

## Resource Management as a State Machine

Deployment and configuration can be thought of as a finite state machine where deployment tasks are completed by the transitions that move a resource from one state to the next. A "state" represents the condition of a resource at a point in time. A "transition" represents the actions that are performed to move the resource from one state to another state. A resource only moves from one state to another by successful execution of transition.

In this sense, resource "state" can be thought of as an attribute of a resource that is stored in a resource administration system, i.e. a database. When an administrator uses the admin system to check the state of a resource they are viewing the single source of truth for that resource's condition. If the resource changes state it is because the admin system executed a transition, without error, that performed the work necessary to move it to the new state. Maintaining the admin system as the single source of truth means that the admin system has sole responsibility for persisting the resource state and it has sole responsibility for initiating transitions that change resource state. The admin system's view of "state" is very concrete: it's a field in a database that represents a state in a state machine. The admin system's view of "transition", however, is very abstract. It has no idea how a transition is implemented, just that it is implemented and that it can be initiated upon request. Transition "implementations" are the point where the conceptual state model is adapted to real world resources.

The following diagram identifies typical tasks that are completed during transitions in order to move a resource through its deployment and configuration lifecycle. It doesn't matter if a transition implementation is automated, manual, or a combination. What matters is:

* The admin system initiates the transition.
* The transition leaves the resource in a condition that is conceptually consistent with the lifecycle model.
* The admin system receives unequivocal notification of transition success or failure.

![state model](images/resource-state-model-generic-impl.png)
<br>*Generic resource management lifecycle with described state transitions.*

## Automated Resource Management

There is no requirement that transitions are automated in order to implement a resource manager. All transitions could be work orders completed manually by technicians. If transitions are automated, however, then resource lifecycle management can be automated. The limits of automation are: i) the physical installation of new equipment, ii) physical removal of retired equipment, and iii) the highest level of management input that is necessary to direct the admin system via a user interface.

### Automating configuration of server resources

Automated deployment and configuration of servers is possible by combining mature network system management services, network boot services, metal-as-a-service (MaaS) methodologies for initial system bring up, and infrastructure-as-code (IaC) methodologies for configuration.

Specifically:

* Use [IPMI] for network access to system management controllers
* Use [PXE] for network boot, which employs standard [DHCP] and [TFTP] network services
* Prefer automated operating system installation, as supported by individual OS vendors
* Prefer [IaC] methods supported by leading implementations such as [Puppet] and [Ansible]

The role of this document is to identify where these technologies are used to implement automated server deployment and configuration in the context of the resource lifecycle management model. They are not discussed individually in depth.

Note that [IPMI] is a deprecated standard but is still in wide use. New system management standards, such as [Redfish], fulfill an equivalent purpose.

### Automating configuration network resources

Networking equipment can be treated as a resource in the resource lifecycle model, both at the level of a switch and hierarchically at the level of individual network ports. As such, it's possible to dynamically deploy and configure network resources if configuration interfaces and API's exist. For example, Arista network switches provide [EOS][Arista EOS], an embedded Linux operating system, that can be used automate switch configuration. The presence of an embedded Linux operating system provides the opportunity for rich implementation of [IaC] methodologies directly on the network switch. At the individual port level, Embrionix provides a [REST api][Embrionix REST] to configure individual SFP modules.

These two implementations can be viewed as emerging best practice for network resource configuration:

* Prefer REST API's for device configuration.
* Prefer SSH access to a command line interface.
* Prefer an accessible embedded operating system to enable implementation of rich [IaC] methodologies.

## Resource Deployment State Model - Metal-as-a-Service Example

Metal-as-a-Service ([MaaS]) refers to the automated provisioning of "bare-metal" compute resources in a data center. The term "bare-metal" is a reference to the "bare" configuration state of servers when they are first installed in the data center. "Service" refers to the automated management of deployment and configuration of these server resources. This is often described as "cloud style provisioning" because it is representative of the methodologies used by large internet service providers who provide "cloud" computing resources.

[MaaS] encompasses automation of the following:

* server hardware identification
* firmware configuration
* allocation of server resources
* operating system installation
* application software installation and configuration
* network configuration
* decommissioning

Metal-as-a-Service (MaaS) implementation patterns leverage very mature industry standards to automate system management and monitoring, network boot, IP address management. MaaS systems leverage these standards by adding automation tooling and administration systems that support managing many system reliably and efficiently at production scale.

| Standards | |
|---|---|
|[DHCP]| Dynamic Host Configuration Protocol | IP address assignment, and provider of PXE boot configuration. |
|[TFTP]| Trivial File Transfer Protocol | File transfer protocol used to load the network boot executable image. |
|[PXE]| Preboot Execution Environment | Network boot capability built on [DHCP] and [TFTP]. Built into system firmware. |
|[IPMI]| Intelligent Platform Management Interface | Out-of-band system management and monitoring independent of the host CPU and OS. Independent network interface, controller, and firmware. |

### Example Existing Industry Solutions:

* [Ubuntu MaaS] is an example of an existing commercial implementation. The phrase "metal-as-a-service" is generic but is commonly associated with Ubuntu's implementation.
* [GitHub metal cloud] is an example of a proprietary implementation. It is a private GitHub implementation but is documented in blog articles. The foundation implementation patterns are identical to [Ubuntu MaaS].

### Metal-as-a-Service represented using the resource model

The following diagrams map typical [MaaS] server configuration operations onto the resource model. The operations described in each transition can be entirely automated with the possible exception of administrator management input to allocate, and retire, server resources.

![state model maas impl](images/resource-state-model-maas-impl.png)
<br>*Resource lifecycle state model metal-as-a-service example.*

### Separate Admin and Production Networks

[MaaS] systems use a server's system management controller to configure, monitor, and control the server via [IPMI]. These interfaces are typically configured on a dedicated administration network that is separate from production networks. In addition, network interfaces are configured for admin network [PXE] boot, automated OS install, and [IaC] configuration. Configuring a server's production network interfaces is the responsibility of [IaC] tooling. An individual server's network configuration happens in conjunction with configuration of dependent network services (i.e. switches, ports, [DHCP] servers, [IPAM] systems). A fully automated deployment system requires no manual human configuration of production servers, or production network services.

![overview](images/deploy-network-overview.png)
<br>*Independent admin and production network.*

## Resource Deployment State Model - Network Switch Port Example

Implementation of network configuration using [IaC] methodologies is enabled by network switch and port interfaces that support automated configuration. See, for example, [CBC's implementation of IaC configuration of Embrionix emsfp EB22 modules][CBC Embrionix GitHub] using [Ansible] playbooks. This opens the possibility of treating network switches, and individual network ports, as resources that can be managed as part of a resource management system that implements automated deployment and configuration. A resource lifecycle state model example that might implement this is shown below. It builds on [CBC's Ansible configuration for Embrionix SFP modules][CBC Embrionix GitHub]. This example is a proof of feasibility that is intended to demonstrate how a network resource adapts to the resource lifecycle model.

![state model network switch impl](images/resource-state-model-network-switch-port-impl.png)
<br>*Resource lifecycle state model network switch port example.*

## [NMOS] Integration Considerations

[NMOS] refers to Networked Media Open Specifications that are developed by [AMWA] for use in IP-based media facilities to define a control and management layer in addition to existing media transport layers.

Resource discovery and registration is a special consideration when integrating [NMOS] resources.

### Two Registry Problem

The [MaaS] methodologies discussed in this document implement administration systems that have a resource registry at their core. A [MaaS] resource registry is the single-source of truth for all resources that are administered by the [MaaS] system. The existence of a single-source-of-truth is a best practice. Breaking that would be an anti-pattern. The [MaaS] admin system uses the resource registry to manage allocation, pooling, staging, commitment, and acceptance of individual resources. The resource registry is a fundamental, and critical, system component that would typically be implemented with great care using a high availability, redundant, database system. For example, [Ubuntu's MaaS][Ubuntu MaaS] system builds its admin services using a redundant [PostgreSQL] cluster.

[NMOS] devices have their own unique registration requirements. They expect to find an [AMWA IS-04] compliant [NMOS] registration service on their network and use that service to register their identity and capabilities.

This creates a "two registry problem": if a [MaaS] resource management system implements one resource registry, and an NMOS system implements another dedicated NMOS only registry, then systems administrators lose their single source of truth. Their view of the facility is now split between the NMOS universe and everything else. This adds system development and administration complexity - possibly substantial. It risks compromising the benefits for which [MaaS] and [IaC] methodologies were introduced to begin with.

![overview](images/nmos-two-registry-problem.png)
<br>*NMOS two registry problem. The NMOS registry is outside the resource registry. Multiple sources of truth confounds reliable system management.*

### Two Registry Solution

The simplest solution to the "two registry problem" is to fully embrace [NMOS registration][AMWA IS-04] into the the core resource management system. This means implementing an NMOS registration service that operates as an integral component of the larger resource registry service. There is, then, no attempt to import, synchronize, or adapt a separate external NMOS registry into the larger, single-source-of-truth, system wide resource registry. The NMOS registry simply becomes an interface by which NMOS devices register directly with the same core resource management system where all other resources are registered. NMOS devices become peers of all other resources and experience the same fundamental resource life cycle management. System developers and administrators maintain a single-source-of-truth view of the system wide resources under management.

![overview](images/nmos-two-registry-solution.png)
<br>*NMOS two registry solution. Implement the NMOS registry as an integral part of the system wide resource registry. Single source of truth enables reliable system management.*

## Security

Automated deployment and configuration, metal-as-a-service implementations, and infrastructure-as-code methodologies, are significant departures from the manual processes traditionally employed in data centers and particularly in media organizations that often lag in adoption of IT industry best practices. Applying best practices to security is particularly critical when implementing deployment and configuration automation. Secure authorization and communication does more than limit intentional abuse, it also, and importantly, helps prevent accidental configuration errors that have potential to create substantial service disruption.

This document suggests best practices to consider. It is not a complete set of recommendations. These are offered in recognition of the fact that good security practices are a critical foundational element of an automation system.

### Build on [AMWA BCP-003]

 * [OAuth2] secure user authorization
 * TLS 1.2 for secure socket communication for WEB interfaces
 * X.509 certificate installation support
 * HTTPS exclusively for WEB interfaces, including REST API's
 * REST API's use Authorization headers and Json Web Tokens

These recommendations conform to [AMWA BCP-003] "Security recommendations for NMOS APIs". AMWA BCP-003 describes best practices for implementing secure web interfaces using HTTPS and OAuth2 user authentication.

### Additional recommendations beyond [AMWA BCP-003]

 * [SSH] access secured by OAuth2 user authorization
 * [SSH] access secured by SSH-authorized keys
 * X.509 certificate support for SSH-key authorization

[IaC] tooling normally requires [SSH] access to the systems under configuration. Embedded operating systems, e.g. [Arista EOS], also use [SSH]. Securing SSH configuration is critical to the security of the entire system. SSH user authorization should use OAuth2. SSH authorized keys are preferred, and normally necessary, for automated SSH login. Systems that support SSH login should provide methods for installing public keys to enable SSH key authorization. X.509 certificate based key authorization is preferred if supported by the SSH implementation. Key management is critical. Keys must be carefully managed and not left to developers, or inexperienced administrators, to implement on an ad-hoc basis.

It is recommended that [AMWA] extend its security recommendations to include [SSH] configuration best practices and that that be reconciled with [AMWA BCP-003] and any other security recommendations published by [AMWA].

### Service Accounts

 * Use service accounts for server-to-server interaction

Automated server to server interactions in trusted environments that are not performed on behalf of an end user should use service accounts. A service account is an account that belongs to an application instead of an individual end user. This is particularly important if zero-human-configuration production systems is an implementation goal. In a zero-human-configuration environment no end-user account is authorized to access production systems or production networking equipment. Service accounts are the best solution.

Service account authorization is supported using [OAuth2] "two legged" authentication. See:[OAuth 2.0 Client Credentials Grant][OAuth2 Two Legged].

It is recommended that [AMWA] extend its security recommendations to include service account recommendations for secure server-to-server communication. This may be a gap in [AMWA BCP-003], or it may be part of a new best practice that has to be developed.

#### [CICD] use of service accounts

Continuous Integration and Continuous Delivery [CICD] methodologies are a natural extension of dynamic configuration and resource management practices. CICD encourages end-to-end, development-to-deployment, automation. CICD best practices require services-accounts to provide secure and reliable access to production systems. CICD methodologies mix user account authorization for development with service account authorization for deployment. Clear distinction between the two account types contributes to reliable and safe production deployment.

## Appendix - Resource State Model: Example fuller representation

A real-world implementation of a resource life-cycle model is necessarily more complex than the conceptual model presented here. Additional complexities may include:

* Additional states are required to implement requirements such as reservation of resources, or putting resources offline for maintenance.
* The requirement for a fuller set of transitions between states than is represented by a simple conceptual model.
  * e.g. to return to "available" from "allocated" without ever having been staged
  * e.g. retiring a registered resource before ever having made it available
* The real-world requirement for robust exception handling that introduces error states.

The finite-state-machine model below models these additional complexities.

![fsm](dot/gen/resource-fsm-complex.png)
<br>
*Example fuller representation of a resource lifecycle finite state machine. Blue transitions represent the simpler conceptual model transitions.*

| Current State | Transition | Next State |
|---|---|---|
|start| T_new_register |registered|
|registered| T_make_new_available |available|
|registered| T_retire |retired|
|registered| T_from_reg_error |error|
|available| T_allocate |allocated|
|available| T_retire |retired|
|available| T_put_offline |offline|
|available| T_reserve |reserved|
|reserved| T_make_existing_available |available|
|reserved| T_allocate |allocated|
|reserved| T_retire |retired|
|reserved| T_put_offline |offline|
|offline| T_make_existing_available |available|
|offline| T_retire |retired|
|allocated| T_stage |staged|
|allocated| T_commit |committed|
|allocated| T_make_existing_available |available|
|allocated| T_from_alloc_error |error|
|staged| T_commit | committed |
|commited| T_accept |accepted|
|accepted| T_release |released|
|released| T_make_existing_available |available|
|released| T_retire |retired|
|released| T_from_release_error |error|
|error| T_error_recover | registered |
|error| T_error_recover | allocated |
|error| T_error_recover | released |
|error| T_error_recover | offline |
|error| T_retire | retired |
|retired| T_end_of_life |end|

*Example state transition table.*
<br><br>

| Transition | Activity or Processing |
|---|---|
|T_new_register | Register the identity of a new resource. |
|T_make_new_available | Perform processing to make a new resource available. |
|T_make_existing_available | Perform processing to return an existing resource to available. |
|T_allocate | Allocate a resource for production deployment. |
|T_stage | Perform first phase of configuration to prepare a resource. |
|T_commit | Perform final phase of configuration for role and commit resource to production. |
|T_accept | Production acceptance of committed resource. |
|T_put_offline | Perform processing to put an existing resource offline. |
|T_release | Perform processing to release a deployed resource. |
|T_reserve | Move a resource into reserved state. |
|T_retire | Perform processing to decommission a resource. |
|T_from_alloc_error | Notify admin, error transitioning out of allocated state. |
|T_from_reg_error | Notify admin, error transitioning out of registered state. |
|T_from_release_error | Notify admin, error transitioning out of released state. |
|T_error_recover | Return to pre-error state, retry last event. |
|T_end_of_life | Perform resource end life tasks, e.g. remove resource form facilities. |

*Example transition descriptions.*


## Appendix - Summary of all referenced URL's

| |
|---|
|[AMWA]|
|[AMWA BCP-003]|
|[AMWA IS-04]|
|[Ansible]|
|[Arista EOS]|
|[CBC Embrionix GitHub]|
|[CICD]|
|[DHCP]|
|[Embrionix REST]|
|[GitHub metal cloud]|
|[IPAM]|
|[IPMI]|
|[IaC]|
|[MaaS]|
|[NMOS]|
|[OAuth2]|
|[OAuth2 Two Legged]|
|[PXE]|
|[PostgreSQL]|
|[Puppet]|
|[Python]|
|[Redfish]|
|[SSH]|
|[TFTP]|
|[Ubuntu MaaS]|


<!-- Update the reference table using the following bash command:
(IFS=$'\n'; for url in $(grep ]: Overview.md  | cut -d: -f1 | sed 's/\[//' | sed 's/\]//' | sort); do echo "|[$url]|"; done)
-->

<!-- REFERENCES -->
[DHCP]: https://tools.ietf.org/html/rfc2131
[IPAM]: https://docs.microsoft.com/en-us/windows-server/networking/technologies/ipam/ipam-top
[IPMI]: https://www.intel.ca/content/www/ca/en/products/docs/servers/ipmi/ipmi-home.html
[TFTP]: https://tools.ietf.org/html/rfc1350
[PXE]: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
[Redfish]: https://redfish.dmtf.org/
[IaC]: https://docs.microsoft.com/en-us/azure/devops/learn/what-is-infrastructure-as-code
[Puppet]: https://puppet.com/
[Ansible]: https://www.ansible.com/
[Arista EOS]: https://www.arista.com/en/products/eos
[Embrionix REST]: https://www.embrionix.com/resource/emSFP-Restful-API-documentations
[CBC Embrionix GitHub]: https://github.com/cbcrc/ansible-embrionix
[NMOS]: https://www.amwa.tv/nmos
[PostgreSQL]: https://www.postgresql.org/
[AMWA IS-04]: http://amwa-tv.github.io/nmos-discovery-registration/
[AMWA BCP-003]: https://amwa-tv.github.io/nmos-api-security/
[SSH]: https://www.ssh.com/ssh/
[AMWA]: https://www.amwa.tv/
[OAuth2]: https://oauth.net/2/
[OAuth2 Two Legged]: https://oauth.net/2/grant-types/client-credentials/
[CICD]: https://stackify.com/what-is-cicd-whats-important-and-how-to-get-it-right/

<!-- TODO: try to find a generic MaaS reference -->
[MaaS]: https://maas.io/docs

[Ubuntu MaaS]: https://maas.io
[GitHub metal cloud]: https://github.blog/2015-12-01-githubs-metal-cloud
[Python]: https://www.python.org/
