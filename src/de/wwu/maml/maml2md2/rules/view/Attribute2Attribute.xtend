package de.wwu.maml.maml2md2.rules.view

import de.wwu.maml.dsl.maml.InteractionProcessElement
import de.wwu.maml.dsl.maml.ParameterConnector
import de.wwu.maml.dsl.mamldata.CustomType
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.model.DataType2ModelElement
import de.wwu.md2.framework.mD2.Attribute
import de.wwu.md2.framework.mD2.Entity
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*

class Attribute2Attribute extends Elem2Elem {
	
	public static final String ruleID = "Attribute->Attribute"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	
	/**
	 * Maps MAML attribute (view layer) to MD2 attribute (data layer) for later usage
	 */
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(InteractionProcessElement))
			.forEach[src |
				recursiveAttributeMapping(src.parameters)
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
	
	def void recursiveAttributeMapping(Iterable<ParameterConnector> connectors){
		// filter relevant connectors
		val dataRelevantConnectors = connectors.filter[it.targetElement instanceof de.wwu.maml.dsl.mamlgui.Attribute]
		
		dataRelevantConnectors.forEach[
			val parent = it.sourceElement
			val child = it.targetElement as de.wwu.maml.dsl.mamlgui.Attribute
			switch parent{
				InteractionProcessElement: {
					val corr = child.getOrCreateCorrModelElement(ruleID)
					val entity = parent.dataType.getOrCreateCorrModelElement(DataType2ModelElement.ruleID).targetElement as Entity
					corr.targetElement = entity.attributes.filter[it.name == child.description.allowedAttributeName]?.head
				}
				Attribute: {
					val corr = child.getOrCreateCorrModelElement(ruleID)
					val entity = parent.type.getOrCreateCorrModelElement(DataType2ModelElement.ruleID).targetElement as Entity
					corr.targetElement = entity.attributes.filter[it.name == child.description.allowedAttributeName]?.head
				}
			}
			
			// Recursive call for sub-params
			recursiveAttributeMapping(child.parameters)
		]		
	}
	
	/**
	 * Helper to get MD2 attribute (data element) for a MAML attribute (view element)
	 * Dependency:
	 * - ModelElements
	 */  
	def Attribute MD2AttributeForMamlAttribute(de.wwu.maml.dsl.mamlgui.Attribute attr, ParameterConnector connector){
		val container = connector.sourceElement.eContainer
		switch container{
			Attribute: {
				// Nested attribute
				if(container.type instanceof CustomType) {
					return (container.type.getOrCreateCorrModelElement(ruleID) as Entity).attributes.filter[it.name == attr.description]?.head
				}	
			}
			InteractionProcessElement: {
				// Attribute of custom type within IPE 
				return (container.dataType.getOrCreateCorrModelElement(ruleID) as Entity).attributes.filter[it.name == attr.description]?.head 
			}
			// TODO transitive relationships 
		}
	}
}