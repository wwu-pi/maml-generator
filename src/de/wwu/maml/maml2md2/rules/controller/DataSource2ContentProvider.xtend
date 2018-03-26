package de.wwu.maml.maml2md2.rules.controller

import de.wwu.maml.dsl.maml.DataSource
import de.wwu.maml.dsl.maml.LocalDataSource
import de.wwu.maml.dsl.mamldata.ComplexType
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.model.DataType2ModelElement
import de.wwu.md2.framework.mD2.ContentProvider
import de.wwu.md2.framework.mD2.Controller
import de.wwu.md2.framework.mD2.ModelElement
import de.wwu.md2.framework.mD2.ReferencedModelType
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*
import de.wwu.maml.dsl.maml.Model
import de.wwu.md2.framework.mD2.RemoteConnection

class DataSource2ContentProvider extends Elem2Elem {
	
	public static final String ruleID = "LocalDataSource->ContentProvider"
	public static final String ruleIDmultiCP = ruleID + "[multi]"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	 
	override def sourceToTarget() {
		// TODO limit multicontentprovider generation for types which are used in selection steps only
			
		// Local CP
		sourceModel.allContents.filter(typeof(DataSource))
			.forEach[src |
				val cp = createMD2ContentProvider(src, false)
				cp.local = true
				
				val cpMulti = createMD2ContentProvider(src, true)
				cpMulti.local = true
			]
			
		// Remote CP
		sourceModel.allContents.filter(typeof(DataSource))
			.forEach[src |
				val cp = createMD2ContentProvider(src, false)
				cp.connection = null //TODO
				
				val cpMulti = createMD2ContentProvider(src, true)
				cpMulti.connection = null //TODO
			]
	}
	
	override def targetToSource() {
//		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
//			.forEach[m |
//				val corr = m.getOrCreateCorrModelElement(ruleID)
//				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
//				sourceModel.MAMLResource.contents += source
//			]
	}
	
	def createMD2ContentProvider(DataSource src, boolean isMultiProvider){
		// Create element and its content
		val corr = src.getOrCreateCorrModelElement(if(isMultiProvider){ ruleIDmultiCP } else { ruleID })
		val cp = corr.getOrCreateTargetElem(targetPackage.contentProvider) as ContentProvider
		
		if(src.dataType instanceof ComplexType){
			cp.name = src.toUniqueName(src.dataType.dataTypeName + if(isMultiProvider){ "MultiProvider" } else { "Provider" }).toFirstUpper
			
			val dataTypeCorr = src.dataType.getOrCreateCorrModelElement(DataType2ModelElement.ruleID)
			val targetType = createTargetElement(targetPackage.referencedModelType) as ReferencedModelType
			targetType.entity = dataTypeCorr.targetElement as ModelElement
			targetType.many = isMultiProvider
			cp.type = targetType
			
			// Local or remote provider
			if(src instanceof LocalDataSource){
				cp.local = true
			} else {
				cp.connection = (src.eContainer.eContainer as Model).getCorrModelElem(Model2Controller.ruleIDremoteConnection)?.head?.targetElement as RemoteConnection
			}
								
			// Attach to container 
			val container = resolveElement(targetPackage.controller, Model2Controller.ruleID)
			(container as Controller)?.controllerElements.add(cp)
			
			MD2ControllerContent.add(cp)
		}
		
		return cp
	}
}