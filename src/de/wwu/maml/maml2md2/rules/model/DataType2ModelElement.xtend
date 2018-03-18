package de.wwu.maml.maml2md2.rules.model

import de.wwu.maml.maml2md2.rules.Elem2Elem
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.Resource

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*
import de.wwu.md2.framework.mD2.EnumBody
import org.eclipse.xtext.findReferences.TargetURIs.Key
import de.wwu.md2.framework.mD2.Model

class DataType2ModelElement extends Elem2Elem {
	
	public static final String ruleID = "DataType->ModelElement"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	
	override def sourceToTarget() {
		// Enum
		sourceModel.allContents.filter(typeof(de.wwu.maml.dsl.mamldata.Enum))
			.forEach[src |
				// Create element and its content
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val enum = corr.getOrCreateTargetElem(targetPackage.enum) as de.wwu.md2.framework.mD2.Enum
				enum.name = src.name
				enum.enumBody = createTargetElement(targetPackage.enumBody) as EnumBody
				val values = enum.enumBody.elements
				for(value : src.values){
					values.add(value.value)
				}
				
				// Attach to container 
				val container = resolveElement(targetPackage.model, Model2Model.ruleID)
				(container as Model)?.modelElements.add(enum)
				
				targetModel.getMD2ModelResource.contents += enum
			]
			
		// Entity
	}
	
	override def targetToSource() {
//		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
//			.forEach[m |
//				val corr = m.getOrCreateCorrModelElement(ruleID)
//				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
//				sourceModel.MAMLResource.contents += source
//			]
	}
	
}