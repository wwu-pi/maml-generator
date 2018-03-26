package de.wwu.maml.maml2md2.rules.view

import de.wwu.maml.dsl.maml.CreateEntity
import de.wwu.maml.dsl.maml.InteractionProcessElement
import de.wwu.maml.dsl.maml.ParameterConnector
import de.wwu.maml.dsl.maml.ShowEntity
import de.wwu.maml.dsl.maml.UpdateEntity
import de.wwu.maml.dsl.mamlgui.AccessType
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.md2.framework.mD2.Label
import de.wwu.md2.framework.mD2.ViewFrame
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*

class ProcessElement2ViewFrame extends Elem2Elem {
	
	public static final String ruleID = "ProcessElement->ViewFrame"
	private val Attribute2ViewElement viewElementTransformer; 
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
		
		viewElementTransformer = new Attribute2ViewElement(src, trgt, corr)
	}
	 
	/* 
	 * Dependencies:
	 * - DataType (for attribute transformation)
	 */
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(InteractionProcessElement))
			.forEach[src |
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val viewFrame = corr.getOrCreateTargetElem(targetPackage.viewFrame) as ViewFrame
				
				viewFrame.name = src.toUniqueName(src.viewName)
				
				// Transform view content
				val contentElements = src.ipeToViewContent;
				if(contentElements.size == 0){
					// View must contain at least one element
					val viewElem = createTargetElement(targetPackage.label) as Label
					viewElem.text = " "
					viewElem.name = viewElem.toUniqueName("dummyLabel")
					viewFrame.elements.add(viewElem)
				} else {
					// Add real content 
					contentElements.forEach[
						viewFrame.elements.add(it)
					]
				}
				
				// Attach to container
				MD2ViewContent.add(viewFrame)
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
	
	def ipeToViewContent(InteractionProcessElement ipe){
		// Prepare ordered list of flattened elements to show 
		val orderedParams = ipe.getOrderedParametersFlattened
				
		val guiElements = switch ipe {
			CreateEntity,
			UpdateEntity: ipe.transformCreateUpdateEntity(orderedParams)
			ShowEntity: ipe.transformCreateUpdateEntity(orderedParams)
			//TODO more view types
		}
		
		return guiElements
	}
	
	def transformCreateUpdateEntity(InteractionProcessElement ipe, Iterable<ParameterConnector> params){
		// Transform each element to viewElement
		val viewElements = params.flatMap[
			viewElementTransformer.sourceToTarget(it, it.accessType === AccessType.WRITE)
		]
		
		return viewElements
	}
	
	def transformShowEntity(ShowEntity show, Iterable<ParameterConnector> params){
		// Transform each element to viewElement
		val viewElements = params.flatMap[
			viewElementTransformer.sourceToTarget(it, false)
		]
		
		return viewElements
	}	
}